# Stolen from https://github.com/naqvis/crystal-vips/blob/0f4d3914985865a020168b0f48ece07416eeb459/example/captcha_generator.cr

require "vips"
require "base58"

# Captcha generator
# Reference: https://github.com/libvips/libvips/issues/898

class Captcha
  getter code : String
  @final : Vips::Image

  def initialize(code : String? = nil, length : Int32 = 4, @format : String = "webp")
    code = Random.base58(length) if code.nil?
    @code = code

    code_layer = Vips::Image.black 1, 1
    x_position = 0

    code.each_char do |c|
      letter, _ = Vips::Image.text(c.to_s, dpi: 600)

      image = letter.gravity(
        direction: Vips::Enums::CompassDirection::Centre,
        width: letter.width + 50,
        height: letter.height + 50
      )

      image = scale_and_rotate(image)
      image = wobble(image)
      image = random_color(image)
      image = nine_bit_srgb(image)
      image = position_to(image: image, x: x_position, y: 0)

      code_layer += image
      code_layer = code_layer.cast(Vips::Enums::BandFormat::Uchar)

      x_position += letter.width
    end

    # remove any unused edges
    code_layer = code_layer.crop(*code_layer.find_trim(background: 0))

    # make an alpha for the code layer: just a mono version of the image, but scaled
    # up so letters themeselves are not transparent
    alpha = (code_layer.colourspace(space: Vips::Enums::Interpretation::Bw) * 3)
      .cast(format: Vips::Enums::BandFormat::Uchar)
    code_layer = code_layer.bandjoin(alpha)

    # make a white background with random speckles
    speckles = Vips::Image.gaussnoise(
      width: code_layer.width,
      height: code_layer.height,
      mean: 400,
      sigma: 200,
    )
    background = (1..3).reduce(speckles) do |a, _|
      a.bandjoin(speckles).copy(
        interpretation: Vips::Enums::Interpretation::Srgb
      ).cast(format: Vips::Enums::BandFormat::Uchar)
    end

    # composite the code over the background
    @final = background.composite(
      image: code_layer,
      mode: Vips::Enums::BlendMode::Over
    )
  end

  def base64
    slice = @final.write_to_buffer("%.#{@format}")
    @base64 ||= Base64.encode(slice)
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

  # position at our write position in the image
  private def position_to(image, x, y)
    image.embed(x, y, image.width + x, image.height + y)
  end

  # random scale and rotate
  private def scale_and_rotate(image)
    image.similarity(
      scale: Random.rand(0.2) + 0.8,
      angle: Random.rand(40) - 20
    )
  end

  # random color
  private def random_color(image)
    color = (1..3).map { Random.rand(255) }
    image.ifthenelse(color, 0, true)
  end

  # tag as 9-bit srgb
  private def nine_bit_srgb(image)
    image.copy(
      interpretation: Vips::Enums::Interpretation::Srgb
    ).cast(Vips::Enums::BandFormat::Uchar)
  end

  # random wobble
  private def wobble(image)
    # a warp image is a 2D grid containing the new coordinates of each pixel with
    # the new x in band 0 and the new y in band 1
    #
    # you can also use a complex image
    #
    # start from a low-res XY image and distort it

    xy = Vips::Image.xyz(image.width // 20, image.height // 20)
    x_distort = Vips::Image.gaussnoise(xy.width, xy.height)
    y_distort = Vips::Image.gaussnoise(xy.width, xy.height)
    xy += (x_distort.bandjoin(y_distort) / 150)
    xy = xy.resize(20)
    xy *= 20

    # apply the warp
    image.mapim(xy)
  end
end
