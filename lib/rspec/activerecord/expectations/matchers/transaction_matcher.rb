module RSpec::ActiveRecord::Expectations
  module Matchers
    class TransactionMatcher
      attr_reader :collector, :failure_message, :failure_message_when_negated
      attr_reader :quantifier

      def initialize(transaction_type)
        @collector    = Collector.new
        @transaction  = transaction_type

        self.at_least(1)
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

      def failure_message
        type_msg = case @transaction
                   when :transaction_queries
                     "execute a transaction"
                   when :rollback_queries
                     "roll back a transaction"
                   when :commit_queries
                     "commit a transaction"
                   end

        "expected block to #{type_msg}, but it didn't do so"
      end

      def failure_message_when_negated
        if @count == 1
          negated_message_singular
        else
          negated_message_plural
        end
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

      private

      # MATCHERS / ACTUAL COMPARISON

      def compare_less_than
        count = @collector.queries_of_type(@transaction)

        @failure_message = "expected block to execute fewer than #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute fewer than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count < @quantifier
      end

      def compare_less_than_or_equal_to
        count = @collector.queries_of_type(@transaction)

        # boy this negated operator is confusing. don't use that plz.
        @failure_message = "expected block to execute at most #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute any less than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count <= @quantifier
      end

      def compare_greater_than
        count = @collector.queries_of_type(@transaction)

        @failure_message = "expected block to execute greater than #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute greater than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count > @quantifier
      end

      def compare_greater_than_or_equal_to
        count = @collector.queries_of_type(@transaction)

        # see above, negating this matcher is so confusing.
        @failure_message = "expected block to execute at least #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute any more than #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count >= @quantifier
      end

      def compare_exactly
        count = @collector.queries_of_type(@transaction)

        @failure_message = "expected block to execute exactly #{@quantifier} #{humanized_query_type}, but it executed #{count}"
        @failure_message_when_negated = "expected block not to execute exactly #{@quantifier} #{humanized_query_type}, but it executed #{count}"

        count == @quantifier
      end

      def negated_message_singular
        pre_msg, post_msg  = case @transaction
                             when :transaction_queries
                               ["execute a transaction", "executed one"]
                             when :rollback_queries
                               ["roll back a transaction", "rolled one back"]
                             when :commit_queries
                               ["commit a transaction", "committed one"]
                             end

        "expected block not to #{pre_msg}, but it #{post_msg}"
      end

      def negated_message_plural
        pre_msg, post_msg = case @transaction
                            when :transaction_queries
                              ["execute a transaction", "executed #{@count} transactions"]
                            when :rollback_queries
                              ["roll back a transaction", "rolled back #{@count} transactions"]
                            when :commit_queries
                              ["commit a transaction", "committed #{@count} transactions"]
                            end

        "expected block not to #{pre_msg}, but it #{post_msg}"
      end

      def humanized_query_type
        @query_type.to_s.gsub("_", " ")
      end

      def humanized_quantifiers(n) # WEW
        if n == 1
          case @transaction
          when :transaction_queries
            ["execute a transaction", "executed one"]
          when :rollback_queries
            ["roll back a transaction", "rolled one back"]
          when :commit_queries
            ["commit a transaction", "committed one"]
          end
        else
          case @transaction
          when :transaction_queries
            ["execute a transaction", "executed #{@count} transactions"]
          when :rollback_queries
            ["roll back a transaction", "rolled back #{@count} transactions"]
          when :commit_queries
            ["commit a transaction", "committed #{@count} transactions"]
          end
        end
      end
    end
  end
end
