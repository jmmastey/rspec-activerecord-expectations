module RSpec::ActiveRecord::Expectations
  module Matchers
    class TransactionMatcher
      def initialize(transaction_type)
        @collector    = Collector.new
        @transaction  = transaction_type
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        block.call

        @count = @collector.queries_of_type(@transaction)
        @count > 0
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

      private

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
    end
  end
end
