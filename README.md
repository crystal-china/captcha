# captcha

Crystal library that generates image CAPTCHAs.

![](images/example.webp)

All credits goes to [the example code in crystal-vips](https://github.com/naqvis/crystal-vips/blob/0f4d3914985865a020168b0f48ece07416eeb459/example/captcha_generator.cr) by [@naqvis](https://github.com/naqvis).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     captcha:
       github: crystal-china/captcha
   ```

2. Run `shards install`

## Usage

```crystal
require "captcha"

captcha = Captcha.new(length: 6)

# Open a.html to check if it work.
captcha.write_html_file("a.html")

# Return underlying image data as Bytes
captcha.buffer # Bytes[82, 73, 70, 70, 16 ... ]

# A string present the html <image> tag which enbed the image in, use it directly in your page.
captcha.image_tag # <img src="data:image/webp;base64,BASE64_ENCODED_IMAGE_DATA" />

# return the underlying text
captcha.text # nh8S8G
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/crystal-china/captcha/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ali Naqvi](https://github.com/naqvis) creator and maintainer
- [Billy.Zheng](https://github.com/zw963) - maintainer
