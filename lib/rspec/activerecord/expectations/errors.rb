module RSpec::ActiveRecord::Expectations
  class NoComparisonError < ArgumentError
    def message
      "You must provide an entire expectation " \
      "(e.g. expect {}.to execute.less_than(n).queries). " \
      "Try appending `less_than` to your expectation."
    end
  end

  class NoQueryTypeError < ArgumentError
    def message
      "You must provide an entire expectation " \
      "(e.g. expect {}.to execute.less_than(n).queries). " \
      "Try appending `queries` to your expectation."
    end
  end
end
