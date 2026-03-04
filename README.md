# captcha

Crystal library that generates image CAPTCHAs.

![](images/example.webp)

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

captcha = CaptchaGenerator.new(length: 6)

# Return image as base64 string.
captcha.base64

# An <img> tag string that embeds the image for use in an HTML page.
captcha.img_tag # <img src="data:image/webp;base64,BASE64_ENCODED_IMAGE_DATA" />

# You can set image height or width like this: 
captcha.img_tag(height: "50px", width: "100px")

# You can use #write_html_file to preview how the captcha looks in an HTML file.
captcha.write_html_file("test.html")

# return the underlying captcha code
captcha.code # nh8S8G
```
More usage, check [spec](spec/captcha_spec.cr)

You should use this shard with a [memory cache](https://github.com/crystal-cache/cache). 

Refer to the links below for a production use case with Lucky.

### create a cache.

[config/application.cr](https://github.com/crystal-china/website/blob/e779d785c79eadd40068d1a4fd2bdfbe87ff8ad4/config/application.cr#L31)


### Generate a random unique signup_captcha_id and save to cookie.

Then use this random id as key, save the captcha code into cache and render the img_tag

[src/actions/htmx/captcha.cr](https://github.com/crystal-china/website/blob/44af7286f8165ca376a3b84c3af538103bd3243d/src/actions/htmx/captcha.cr#L8-L22)

### get the captcha code from cache use cookie.

Get the captcha_id from the cookie, then retrieve the captcha code from the cache and compare them.

[src/actions/sign_ups/create.cr](https://github.com/crystal-china/website/blob/44af7286f8165ca376a3b84c3af538103bd3243d/src/actions/sign_ups/create.cr#L5-L19)

## limit

You can't create a fully static Crystal binary because it relies on libvips as a dependency. 
If that’s an issue for you, you might want to check out [simple_captcha](https://github.com/crystal-lang/simple_captcha). 

These two libraries should work interchangeably, so you shouldn’t need to change your code.

## Contributing

1. Fork it (<https://github.com/crystal-china/captcha/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ali Naqvi](https://github.com/naqvis) creator and maintainer
- [Billy.Zheng](https://github.com/zw963) - maintainer
