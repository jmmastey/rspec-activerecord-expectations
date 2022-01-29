module RSpec::ActiveRecord::Expectations
  module Matchers
    class TransactionMatcher
      attr_reader :collector, :quantifier, :comparison, :query_type

      def initialize(transaction_type)
        @collector    = Collector.new
        @query_type  = transaction_type
        @message_builder = MessageBuilder.new(self)

        self.at_least(1)
      end

      def failure_message
        @message_builder.failure_message
      end

      def failure_message_when_negated
        @message_builder.failure_message_when_negated
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        raise NoComparisonError unless @match_method

        block.call
        result = @match_method.call
        @collector.finalize

        result
      end

      # QUANTIFIERS

      def less_than(n)
        @quantifier   = n
        @comparison = :less_than
        @match_method = -> { actual_count < @quantifier }
        self
      end
      alias_method :fewer_than, :less_than

      def less_than_or_equal_to(n)
        @quantifier   = n
        @comparison = :less_than_or_equal_to
        @match_method = -> { actual_count <= @quantifier }
        self
      end
      alias_method :at_most, :less_than_or_equal_to

      def greater_than(n)
        @quantifier   = n
        @comparison = :greater_than
        @match_method = -> { actual_count > @quantifier }
        self
      end
      alias_method :more_than, :greater_than

      def greater_than_or_equal_to(n)
        @quantifier   = n
        @comparison = :greater_than_or_equal_to
        @match_method = -> { actual_count >= @quantifier }
        self
      end
      alias_method :at_least, :greater_than_or_equal_to

      def exactly(n)
        @quantifier   = n
        @comparison = :exactly
        @match_method = -> { actual_count == @quantifier }
        self
      end

      def once
        exactly(1).time
      end

      def twice
        exactly(2).times
      end

      def thrice # hehe
        exactly(3).times
      end

      def times
        self # NOOP
      end
      alias_method :time, :times

      def actual_count
        @collector.queries_of_type(@query_type)
      end
    end
  end
end
