require "crimage"

class CaptchaGenerator
  getter code : String
  @final : CrImage::RGBA

  def initialize(code : String? = nil, length : Int32 = 4, @format : String = "webp", width : Int32 = 300, height : Int32 = 100, noise_level : Int32 = 20, line_count : Int32 = 6, font_path : String? = nil)
    code = CrImage::Util::Captcha.random_text(length) if code.nil?
    @code = code

    font_path = resolve_font_path(font_path)

    options = CrImage::Util::Captcha::Options.new(
      width: width,
      height: height,
      noise_level: noise_level,
      line_count: line_count
    )

    @final = CrImage::Util::Captcha.generate(code, font_path, options)
  end

  def base64 : String
    @base64 ||=
      begin
        io = IO::Memory.new
        case @format.downcase
        when "png"
          CrImage::PNG.write(io, @final)
        when "jpg", "jpeg"
          CrImage::JPEG.write(io, @final, 90)
        when "webp"
          CrImage::WEBP.write(io, @final)
        when "bmp"
          CrImage::BMP.write(io, @final)
        when "gif"
          CrImage::GIF.write(io, @final)
        when "tif", "tiff"
          CrImage::TIFF.write(io, @final)
        else
          @format = "webp"
          CrImage::WEBP.write(io, @final)
        end

        Base64.strict_encode(io.to_slice)
      end
  end

  def img_tag(width : String? = nil, height : String? = nil) : String
    String.build do |io|
      io << <<-HEREDOC
<img src="data:image/#{@format};base64,#{base64}"
HEREDOC

      if width && height
        io << " style=\"width: #{width}; height: #{height};\""
      elsif width
        io << " style=\"width: #{width};\""
      elsif height
        io << " style=\"height: #{height};\""
      end

      io << " />"
    end
  end

  def write_html_file(name) : Nil
    html = <<-HEREDOC
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Base64 Image Demo</title>
  </head>

  <body>
    <h1>显示 captcha 图片</h1>
    #{img_tag}
  </body>
</html>
HEREDOC

    File.write(name, html)
  end

  # Use font config to search sans-serif(系统默认无衬线) fonts
  private def resolve_font_path(font_path : String?) : String
    return font_path unless font_path.blank?

    output = IO::Memory.new
    error = IO::Memory.new

    begin
      status = Process.run(
        "fc-match",
        ["-f", "%{file}", "sans-serif"],
        output: output,
        error: error
      )
      path = output.to_s.chomp

      unless status.success?
        puts "Error: Running fc-match failed."
        puts ""
        puts error.to_s.chomp
        puts ""

        exit 1
      end

      if path.blank? || !File.exists?(path)
        puts "Error: Font file not found: #{path}"
        puts ""
        puts "Please download a font, or install one with your package manager."
        puts "Quick options:"
        puts "  1. Download Roboto from https://fonts.google.com/specimen/Roboto"
        puts "  2. Extract Roboto-Bold.ttf to fonts/Roboto/static/"
        puts "  3. Or use a system font with -f option"
        puts ""
        puts "See https://github.com/naqvis/crimage/blob/main/fonts/README.md for more details."

        exit 1
      end

      path
    rescue File::NotFoundError
      puts "Error: fontconfig is not installed. Please install it with:"
      puts ""
      puts "alpine: apk add --no-cache fontconfig ttf-dejavu"
      puts "Ubuntu: apt-get install -y --no-install-recommends fontconfig"
      puts ""

      exit 1
    end
  end
end
