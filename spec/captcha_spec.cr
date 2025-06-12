require "./spec_helper"

describe Captcha do
  it "passing string works" do
    captcha = Captcha.new("abcD1234")
    captcha.text.should eq "abcD1234"
    captcha.buffer.should be_a Bytes
    captcha.image_tag.should start_with("<img")
  end

  it "passing number work" do
    captcha = Captcha.new(length: 6)
    captcha.text.size.should eq 6
    captcha.buffer.should be_a Bytes
    captcha.image_tag.should start_with("<img")
  end
end
