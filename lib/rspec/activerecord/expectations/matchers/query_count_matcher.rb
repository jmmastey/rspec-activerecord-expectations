module RSpec::ActiveRecord::Expectations
  module Matchers
    class QueryCountMatcher
      attr_reader :collector, :quantifier, :comparison, :query_type

      def initialize
        @collector = Collector.new
        @message_builder = MessageBuilder.new(self)

        @match_method = nil
        @quantifier   = nil
        @query_type   = nil
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
        raise NoQueryTypeError unless @collector.valid_type?(@query_type)

        block.call
        result = @match_method.call
        @collector.finalize

        result
      end

      # QUANTIFIERS

      def less_than(n)
        @quantifier   = n
        @comparison   = :less_than
        @match_method = -> { actual_count < @quantifier }
        self
      end
      alias_method :fewer_than, :less_than

      def less_than_or_equal_to(n)
        @quantifier   = n
        @comparison   = :less_than_or_equal_to
        @match_method = -> { actual_count <= @quantifier }
        self
      end
      alias_method :at_most, :less_than_or_equal_to

      def greater_than(n)
        @quantifier   = n
        @comparison   = :greater_than
        @match_method = -> { actual_count > @quantifier }
        self
      end
      alias_method :more_than, :greater_than

      def greater_than_or_equal_to(n)
        @quantifier   = n
        @comparison   = :greater_than_or_equal_to
        @match_method = -> { actual_count >= @quantifier }
        self
      end
      alias_method :at_least, :greater_than_or_equal_to

      def exactly(n)
        @quantifier   = n
        @comparison   = :exactly
        @match_method = -> { actual_count == @quantifier }
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

      # helper for message builder

      def actual_count
        @collector.queries_of_type(@query_type)
      end
    end
  end
end
