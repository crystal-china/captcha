# Stolen from https://github.com/naqvis/crystal-vips/blob/0f4d3914985865a020168b0f48ece07416eeb459/example/captcha_generator.cr

require "crimage"
require "base58"

class CaptchaGenerator
  getter code : String
  @final : CrImage::RGBA

  def initialize(code : String? = nil, length : Int32 = 4, @format : String = "webp", width : Int32 = 300, height : Int32 = 100, noise_level : Int32 = 25, line_count : Int32 = 6)
    code = Random.base58(length) if code.nil?
    @code = code

    font_path = File.expand_path("../assets/fonts/Roboto-Bold.ttf", __DIR__)
    raise "Font not found: #{font_path}" unless File.exists?(font_path)

    options = CrImage::Util::Captcha::Options.new(
      width: width,
      height: height,
      noise_level: noise_level,
      line_count: line_count
    )

    @final = CrImage::Util::Captcha.generate(code, font_path, options)
  end

  def base64 : String
    @base64 ||= begin
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
end
