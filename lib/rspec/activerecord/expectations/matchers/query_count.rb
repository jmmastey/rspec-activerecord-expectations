module RSpec::ActiveRecord::Expectations
  module Matchers
    class QueryCountMatcher
      attr_reader :failure_message, :failure_message_when_negated

      def initialize
        @collector = Collector.new

        @match_method = nil
        @comparison   = nil
        @query_type   = nil
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        raise NoComparisonError unless @match_method
        raise NoQueryTypeError unless @collector.valid_type?(@query_type)

        result    = block.call

        !!@match_method.call
      end

      # COMPARISON TYPES

      def fewer_than(n)
        @comparison   = n
        @match_method = method(:match_fewer_than)
        self
      end
      alias_method :less_than, :fewer_than

      # TARGET QUERY TYPES

      def queries
        @query_type = :queries
        self
      end

      private

      # MATCHERS

      def match_fewer_than
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute fewer than #{@comparison} queries, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute fewer than #{@comparison} queries, but it executed #{count}"

        count < @comparison
      end
    end
  end
end
