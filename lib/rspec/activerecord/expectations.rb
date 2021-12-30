module RSpec
  module ActiveRecord
    module Expectations
      def execute
        Matchers::QueryCountMatcher.new
      end
    end
  end
end

require_relative 'expectations/errors'
require_relative 'expectations/collector'
require_relative 'expectations/matchers/query_count'
