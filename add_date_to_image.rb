require 'mini_exiftool'
require 'mini_magick'

# Dodawanie daty na zdjęcie
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
    
    print "\nUkończono dodawanie dat - kliknij enter aby kontynuować..."
    gets.chomp
    system("clear")
  end
end

# Sorotowanie zdjęć
class SortImage
  def initialize(images_path)
    @images_path = images_path
  end

  def sort_images
    sorted_images = Dir.glob(File.join(@images_path, '*.{jpg,jpeg,png,heic}')).sort_by { |image_path| File.mtime(image_path) }

    return sorted_images
  end
end

# Zmiana rozszerzenia zdjęcia
class ChangeImageExtension
  def initialize(images_path)
    @images_path = images_path
  end

  def change_extension(new_extension)
    image_files = Dir.glob(File.join(@images_path, '*'))
    puts "Ilość znalezionych zdjęć: #{image_files.length}.\n\n"

    new_folder = File.join(@images_path, new_extension.upcase)
    FileUtils.mkdir_p(new_folder) unless Dir.exist?(new_folder)

    image_files.each do |file|
      next unless file.downcase.end_with?('.jpg', '.jpeg', '.png', '.heic')

      image = MiniMagick::Image.open(file)
      new_file = File.join(new_folder, File.basename(file).gsub(/\.(jpg|jpeg|png|heic)$/i, ".#{new_extension}"))
      image.write(new_file)
      puts "Zmieniono rozszerzenie: #{File.basename(file)} -> #{File.basename(new_file)}"
    end

    print "\nUkończono zmianę rozszerzeń - kliknij enter aby kontynuować..."
    gets.chomp
    system("clear")
  end

  def show_menu
    puts "+----------------------------------------------------------+"
    puts "|   Wybierz rozszerzenie, na które chcesz zmienić pliki:   |"
    puts "+----------------------------------------------------------+"
    puts "|   1. JPG                                                 |"
    puts "|   2. JPEG                                                |"
    puts "|   3. PNG                                                 |"
    puts "|   4. HEIC                                                |"
    puts "+----------------------------------------------------------+"
    print "Wybierz opcję: "
    choice = gets.chomp.to_i
    system("clear")

    case choice
    when 1
      change_extension('jpg')
    when 2
      change_extension('jpeg')
    when 3
      change_extension('png')
    when 4
      change_extension('heic')
    else
      puts "Nieprawidłowy wybór. Spróbuj ponownie."
    end
  end
end

def main
  system("clear")
  images_path = '/Users/xeross99/Desktop/images'
  done_images_path = '/Users/xeross99/Desktop/images_with_date'

  loop do
    puts "+----------------------------+"
    puts "|   Co chcesz zrobić?        |"
    puts "+----------------------------+"
    puts "|   1. Dodaj datę do zdjęć   |"
    puts "|   2. Zmiana rozszerzenia   |"
    puts "|   3. Sortuj zdjęcia        |"
    puts "|                            |"
    puts "|   0. Wyjście               |"
    puts "+----------------------------+"
    print "Wybierz opcję: "
    choice = gets.chomp.to_s

    case choice
    when '1'
      system("clear")
      add_time_to_image = AddTimeToImage.new(images_path, done_images_path)
      add_time_to_image.add_date_to_images
    when '2'
      system("clear")
      change_extension = ChangeImageExtension.new(images_path)
      change_extension = change_extension.show_menu
    when '3'
      system("clear")
      sort_image = SortImage.new(images_path)
      sorted_images = sort_image.sort_images
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