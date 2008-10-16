module Sass::Script
  # Methods in this module are accessible from the Sass script context.
  # For example, you can write
  #
  #   color = hsl(120, 100%, 50%)
  #
  # and it will call Sass::Script::Functions#hsl.
  #
  # You can add your own functions to this module,
  # but there are a few things to keep in mind.
  # First of all, the arguments passed are (currently undocumented) Sass::Script::Literal objects,
  # Literal objects are also the expected return values.
  #
  # Second, making Ruby functions accessible from Sass introduces the temptation
  # to do things like database access within stylesheets.
  # This temptation must be resisted.
  # Keep in mind that Sass stylesheets are only compiled once
  # at a somewhat indeterminate time
  # and then left as static CSS files.
  # Any dynamic CSS should be left in <style> tags in the HTML.
  module Functions
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    extend self

    # Creates a Sass::Script::Color object from hue, saturation, and lightness.
    # As per the CSS3 spec (http://www.w3.org/TR/css3-color/#hsl-color),
    # hue is in degrees,
    # and saturation and lightness are percentages.
    def hsl(h, s, l)
      # This algorithm is from http://www.w3.org/TR/css3-color#hsl-color
      h, s, l = [h, s, l].map { |a| a.value }
      h = (h % 360) / 360.0
      s /= 100.0
      l /= 100.0

      m2 = l <= 0.5 ? l * (s + 1) : l + s - l * s
      m1 = l * 2 - m2
      Color.new([hue_to_rgb(m1, m2, h + 1.0/3),
                 hue_to_rgb(m1, m2, h),
                 hue_to_rgb(m1, m2, h - 1.0/3)].map { |c| (c * 0xff).round })
    end

    def percentage(value)
      unless value.is_a?(Sass::Script::Number) && value.unitless?
        raise ArgumentError.new("Value is not a unitless number")
      end
      Sass::Script::Number.new(value.value * 100, '%')
    end

    private

    def hue_to_rgb(m1, m2, h)
      h += 1 if h < 0
      h -= 1 if h > 1
      return m1 + (m2 - m1) * h * 6 if h * 6 < 1
      return m2 if h * 2 < 1
      return m1 + (m2 - m1) * (2.0/3 - h) * 6 if h * 3 < 2
      return m1
    end
  end
end