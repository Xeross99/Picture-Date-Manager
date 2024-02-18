require 'mini_exiftool'
require 'mini_magick'

class AddTimeToImage
  def initialize(images_path, done_images_path)
    @images_path = images_path
    @done_images_path = done_images_path
    Dir.mkdir(@done_images_path) unless Dir.exist?(@done_images_path)
  end

  def load_date_from_image(image)
    exif = MiniExiftool.new(image)
    return exif.date_time_original.strftime("%d.%m.%Y") if exif.date_time_original
  end

  def add_date_to_images
    data = Dir.glob(File.join(@images_path, '*.{jpg,jpeg,png,heic}'))

    puts "Ilość znalezionych zdjęć - #{data.length()}.\n\n"

    data.each_with_index do |image_path, index|
      image = MiniMagick::Image.open(image_path)

      text_options = {
        gravity: 'SouthEast',
        pointsize: 200,
        fill: 'white',
        font: "SF-Pro-Semibold",
        draw: "text 50,20 '#{load_date_from_image(image_path)}' fill white stroke black"
      }

      image.combine_options do |c|
        c.fill text_options[:fill]
        c.font text_options[:font]
        c.gravity text_options[:gravity]
        c.pointsize text_options[:pointsize]
        c.draw text_options[:draw]
      end

      output_path = File.join(@done_images_path, File.basename(image_path))
      image.write(output_path)

      puts "#{index+1} - dodano datę do: #{File.basename(image_path)}"
    end
    print "\nUkończono dodawanie dat - kliknij enter aby kontynuować."
    gets.chomp
  end
end

class SortImage
  def initialize(images_path)
    @images_path = images_path
  end

  def sort_images
    # Kod sortujący zdjęcia według określonego kryterium
    # Możesz dostosować ten kod do swoich potrzeb sortowania
    sorted_images = Dir.glob(File.join(@images_path, '*.{jpg,jpeg,png,heic}')).sort_by { |image_path| File.mtime(image_path) }

    # Zwróć posortowane zdjęcia
    return sorted_images
  end
end

def show_menu_options
  puts "+----------------------+"
  puts "|   Co chcesz zrobić?  |\n"
  puts "+----------------------+"
  puts "|1. Dodaj datę do zdjęć|"
  puts "|   2. Sortuj zdjęcia  |"
  puts "|                      |"
  puts "|     0. Wyjście       |"
  puts "+--------------------- +"
  print "Opcja: "
end

def main
  system("clear")
  images_path = '/Users/xeross99/Desktop/images'
  done_images_path = '/Users/xeross99/Desktop/images_with_date'

  loop do
    show_menu_options
    choice = gets.chomp.to_s

    case choice
    when '1'
      system("clear")
      add_time_to_image = AddTimeToImage.new(images_path, done_images_path)
      add_time_to_image.add_date_to_images
    when '2'
      system("clear")
      sort_image = SortImage.new(images_path)
      sorted_images = sort_image.sort_images
      puts "Posortowane zdjęcia: #{sorted_images}"
    when '0'
      system("clear")
      puts "Do widzenia!"
      break
    else
      puts "\n\nNieprawidłowy wybór. Wybierz ponownie."
    end
  end
end

main