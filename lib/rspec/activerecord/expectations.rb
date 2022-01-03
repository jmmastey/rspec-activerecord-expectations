module RSpec
  module ActiveRecord
    module Expectations
      def execute
        Matchers::QueryCountMatcher.new
      end

      def repeatedly_load(klass)
        Matchers::LoadMatcher.new(klass)
      end
    end
  end
end

require_relative 'expectations/errors'
require_relative 'expectations/query_inspector'
require_relative 'expectations/collector'
require_relative 'expectations/matchers/query_count_matcher'
require_relative 'expectations/matchers/load_matcher'
