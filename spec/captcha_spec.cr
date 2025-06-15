require "./spec_helper"

describe Captcha do
  it "passing string works" do
    captcha = Captcha.new("abcD1234")
    captcha.code.should eq "abcD1234"
    captcha.base64.should be_a String
    captcha.img_tag.should start_with("<img")
    captcha.img_tag.should contain("data:image/webp;base64")
  end

  it "passing number work" do
    captcha = Captcha.new(length: 6, format: "png")
    captcha.code.size.should eq 6
    captcha.base64.should be_a String
    captcha.img_tag.should start_with("<img")
    captcha.img_tag.should contain("data:image/png;base64")
    (captcha.img_tag.size > 20000).should be_true
  end

  it "use default work" do
    captcha = Captcha.new
    captcha.code.size.should eq 4
    captcha.base64.should be_a String
    captcha.img_tag.should start_with("<img")
  end
end
