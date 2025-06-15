# captcha

Crystal library that generates image CAPTCHAs.

![](images/example.webp)

All credits goes to [the example code in crystal-vips](https://github.com/naqvis/crystal-vips/blob/0f4d3914985865a020168b0f48ece07416eeb459/example/captcha_generator.cr) by [@naqvis](https://github.com/naqvis), and the
users's discussion in this [libvips issue](https://github.com/libvips/libvips/issues/898).

## Installation

You need install [libvps](https://github.com/libvips/libvips) correctly before use this shard.

check [pre-requisites](https://github.com/zw963/crystal-vips?tab=readme-ov-file#pre-requisites) for details


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

captcha = CaptchaGenerator.new(length: 6)

# Return image as base64 string.
captcha.base64

# A <img> tag string which enbed the image in can use in HTML page.
captcha.img_tag # <img src="data:image/webp;base64,BASE64_ENCODED_IMAGE_DATA" />

# You can set image height or width like this: 
captcha.img_tag(height: "50px", width: "100px")

# you can use #write_html_file to preview how the captcha looks like in a html file.
captcha.write_html_file("test.html")

# return the underlying captcha code
captcha.code # nh8S8G
```
More usage, check [spec](spec/captcha_spec.cr)

You should use this shards with a [memory cache](https://github.com/crystal-cache/cache), consider refer to following links
for a really production usecase of this shards with lucky.

### create a cache.

[config/application.cr](https://github.com/crystal-china/website/blob/e779d785c79eadd40068d1a4fd2bdfbe87ff8ad4/config/application.cr#L31)


### use browser cookie as captcha id to cache the captcha text.

create a browser cookie as captcha_id, then use this id as cache key, and captcha text
as value, and render the img_tag.

[src/actions/htmx/captcha.cr](https://github.com/crystal-china/website/blob/e779d785c79eadd40068d1a4fd2bdfbe87ff8ad4/src/actions/htmx/captcha.cr#L8-L23)

### get the captcha text from cache use cookie.

Get the captcha_id from cookie, then retrive the captcha text from the cache

[sign_ups/create.cr](https://github.com/crystal-china/website/blob/e779d785c79eadd40068d1a4fd2bdfbe87ff8ad4/src/actions/sign_ups/create.cr#L5-L10)

## limit

AFAIK, if you use this shards, you can't built static Crystal binary anymore.


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
