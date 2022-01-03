module RSpec::ActiveRecord::Expectations
  module Matchers
    class LoadMatcher
      def initialize(klass)
        @collector = Collector.new
        @klass = klass.to_s
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        block.call

        @count = @collector.calls_by_name("#{@klass} Load")
        @count > 1
      end

      def failure_message
        "expected block to repeatedly load #{@klass}, but it was loaded #{@count} times"
      end

      def failure_message_when_negated
        "expected block not to repeatedly load #{@klass}, but it was loaded #{@count} times"
      end
    end
  end
end
