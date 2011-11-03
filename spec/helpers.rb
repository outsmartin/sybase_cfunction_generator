module GeneratorHelperMethods
  RSpec::Matchers.define :be_the_same_content do |expected|
    match do |actual|
      strip_whitespace(actual) == strip_whitespace(expected)
    end
    def strip_whitespace(input)
      if input.is_a? Array
        input.map!{|i| i.gsub(/\s/,'')}
      end
      if input.is_a? String
        input.gsub!(/\s/,'')
      end
      input
    end
  end
end

