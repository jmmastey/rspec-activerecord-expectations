module RSpec::ActiveRecord::Expectations
  class MessageBuilder
    attr_reader :matcher, :phrase_builder

    def initialize(matcher)
      @matcher = matcher
      @phrase_builder = case matcher
        when Matchers::QueryCountMatcher then QueryPhrases.new(matcher)
        when Matchers::TransactionMatcher
        else raise ArgumentError
      end
    end

    def failure_message
      "expected block to #{phrase_builder.prefix}, but it #{phrase_builder.suffix}"
    end

    def failure_message_when_negated
      "expected block not to #{phrase_builder.prefix}, but it #{phrase_builder.negative_suffix}"
    end

    private

    # TODO: expect {}.not_to execute.less_than_or_equal_to(3).insert_queries
    # expected block not to execute at most 3 insert queries, but it executed 0

    class QueryPhrases
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher
      end

      def prefix
        "execute #{comparison_phrase} #{query_type_name}"
      end

      def suffix
        if matcher.actual_count == 0
          "didn't execute any"
        else
          "executed #{matcher.actual_count}"
        end
      end

      def negative_suffix
        if matcher.comparison == :exactly
          "did so"
        else
          # borrowing "didn't execute any" above would cause double-negative
          "executed #{matcher.actual_count}"
        end
      end

      private

      def query_type_name
        if matcher.quantifier == 1
          matcher.query_type.to_s.gsub("_", " ").gsub("queries", "query")
        else
          matcher.query_type.to_s.gsub("_", " ")
        end
      end

      def comparison_phrase
        quant = if matcher.quantifier == 1 && matcher.comparison == :exactly
          "a"
        elsif matcher.quantifier == 1
          "one"
        else
          matcher.quantifier
        end

        case matcher.comparison
          when :exactly                   then quant
          when :greater_than              then "more than #{quant}"
          when :greater_than_or_equal_to  then "at least #{quant}"
          when :less_than                 then "less than #{quant}"
          when :less_than_or_equal_to     then "at most #{quant}"
          else raise ArgumentError, "unsupported comparison matcher #{matcher.comparison}"
        end
      end
    end
  end
end
