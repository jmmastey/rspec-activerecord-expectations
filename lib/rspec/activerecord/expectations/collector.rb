module RSpec::ActiveRecord::Expectations
  class Collector
    def initialize
      @inspector  = QueryInspector.new
      @by_name    = {}
      @counts     = QueryInspector.valid_query_types.each_with_object({}) do |query_type, hash|
        hash[query_type] = 0
      end

      ActiveSupport::Notifications.subscribe("sql.active_record", method(:record_query))
    end

    def queries_of_type(type)
      @counts[type] || (raise ArgumentError, "Sorry, #{type} is not a valid kind of query")
    end

    def valid_type?(type)
      @counts.include? type
    end

    def calls_by_name(name)
      @by_name.fetch(name, 0)
    end

    def record_query(*_unused, data)
      categories = @inspector.categorize(data)

      categories.each do |category|
        @counts[category] += 1
      end

      @by_name[data[:name]] ||= 0
      @by_name[data[:name]] += 1
    end
  end
end
