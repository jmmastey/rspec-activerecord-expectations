module RSpec::ActiveRecord::Expectations
  module Matchers
    class QueryCountMatcher
      attr_reader :collector, :failure_message, :failure_message_when_negated

      def initialize
        @collector = Collector.new

        @match_method = nil
        @quantifier   = nil
        @query_type   = nil
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        raise NoComparisonError unless @match_method
        raise NoQueryTypeError unless @collector.valid_type?(@query_type)

        block.call
        result = @match_method.call
        @collector.finalize

        result
      end

      # QUANTIFIERS

      def less_than(n)
        @quantifier   = n
        @match_method = method(:compare_less_than)
        self
      end
      alias_method :fewer_than, :less_than

      def less_than_or_equal_to(n)
        @quantifier   = n
        @match_method = method(:compare_less_than_or_equal_to)
        self
      end
      alias_method :at_most, :less_than_or_equal_to

      def greater_than(n)
        @quantifier   = n
        @match_method = method(:compare_greater_than)
        self
      end
      alias_method :more_than, :greater_than

      def greater_than_or_equal_to(n)
        @quantifier   = n
        @match_method = method(:compare_greater_than_or_equal_to)
        self
      end
      alias_method :at_least, :greater_than_or_equal_to

      def exactly(n)
        @quantifier   = n
        @match_method = method(:compare_exactly)
        self
      end

      # TARGET QUERY TYPES

      RSpec::ActiveRecord::Expectations::QueryInspector.valid_query_types.each do |type|
        define_method type do
          @query_type = type
          self
        end

        singularized_type = type.to_s.gsub('queries', 'query')
        if singularized_type != type.to_s
          define_method singularized_type do
            @query_type = type
            self
          end
        end
      end

      # TODO singularize everything
      alias_method :query, :queries

      private

      def humanized_query_type
        @query_type.to_s.gsub("_", " ")
      end

      # MATCHERS / ACTUAL COMPARISON

      def compare_less_than
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute fewer than #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute fewer than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count < @quantifier
      end

      def compare_less_than_or_equal_to
        count = @collector.queries_of_type(@query_type)

        # boy this negated operator is confusing. don't use that plz.
        @failure_message = "expected block to execute at most #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute any less than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count <= @quantifier
      end

      def compare_greater_than
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute greater than #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute greater than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count > @quantifier
      end

      def compare_greater_than_or_equal_to
        count = @collector.queries_of_type(@query_type)

        # see above, negating this matcher is so confusing.
        @failure_message = "expected block to execute at least #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute any more than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count >= @quantifier
      end

      def compare_exactly
        count = @collector.queries_of_type(@query_type)

        @failure_message = "expected block to execute exactly #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute exactly #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count == @quantifier
      end
    end
  end
end
