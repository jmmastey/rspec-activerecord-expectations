module RSpec
  module ActiveRecord
    module Expectations
      def execute
        Matchers::QueryCountMatcher.new
      end

      def repeatedly_load(klass)
        Matchers::LoadMatcher.new(klass)
      end

      def execute_a_transaction
        Matchers::TransactionMatcher.new(:transaction_queries)
      end

      def rollback_a_transaction
        Matchers::TransactionMatcher.new(:rollback_queries)
      end

      def roll_back_a_transaction
        Matchers::TransactionMatcher.new(:rollback_queries)
      end

      def commit_a_transaction
        Matchers::TransactionMatcher.new(:commit_queries)
      end
    end
  end
end

require_relative 'expectations/errors'
require_relative 'expectations/query_inspector'
require_relative 'expectations/collector'
require_relative 'expectations/message_builder'
require_relative 'expectations/matchers/query_count_matcher'
require_relative 'expectations/matchers/load_matcher'
require_relative 'expectations/matchers/transaction_matcher'
