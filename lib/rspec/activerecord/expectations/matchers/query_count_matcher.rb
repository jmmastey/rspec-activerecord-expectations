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

        result = block.call

        !!@match_method.call
      end

      # COMPARISON TYPES

      def less_than(n)
        @comparison   = n
        @match_method = method(:compare_less_than)
        self
      end
      alias_method :fewer_than, :less_than

      def less_than_or_equal_to(n)
        @comparison   = n
        @match_method = method(:compare_less_than_or_equal_to)
        self
      end
      alias_method :at_most, :less_than_or_equal_to

      def greater_than(n)
        @comparison   = n
        @match_method = method(:compare_greater_than)
        self
      end
      alias_method :more_than, :greater_than

      def greater_than_or_equal_to(n)
        @comparison   = n
        @match_method = method(:compare_greater_than_or_equal_to)
        self
      end
      alias_method :at_least, :greater_than_or_equal_to

      def exactly(n)
        @comparison   = n
        @match_method = method(:compare_exactly)
        self
      end

      # TARGET QUERY TYPES

      RSpec::ActiveRecord::Expectations::QueryInspector.valid_query_types.each do |type|
        define_method type do
          @query_type = type
          self
        end
      end

      # TODO singularize everything
      alias_method :query, :queries

      private

      # MATCHERS

      def compare_less_than
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute fewer than #{@comparison} queries, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute fewer than #{@comparison} queries, but it executed #{count}"

        count < @comparison
      end

      def compare_less_than_or_equal_to
        count = @collector.queries_of_type(@query_type)

        # boy this negated operator is confusing. don't use that plz.
        @failure_message = "expected block to execute at most #{@comparison} queries, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute any less than #{@comparison} queries, but it executed #{count}"

        count <= @comparison
      end

      def compare_greater_than
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute greater than #{@comparison} queries, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute greater than #{@comparison} queries, but it executed #{count}"

        count > @comparison
      end

      def compare_greater_than_or_equal_to
        count = @collector.queries_of_type(@query_type)

        # see above, negating this matcher is so confusing.
        @failure_message = "expected block to execute at least #{@comparison} queries, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute any more than #{@comparison} queries, but it executed #{count}"

        count >= @comparison
      end

      def compare_exactly
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute at #{@comparison} queries, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute #{@comparison} queries, but it executed #{count}"

        count == @comparison
      end
    end
  end
end
