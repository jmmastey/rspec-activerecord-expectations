module RSpec::ActiveRecord::Expectations
  class Collector
    def initialize
      @counts = {
        queries: 0
      }

      ActiveSupport::Notifications.subscribe("sql.active_record", method(:record_query))
    end

    def queries_of_type(type)
      @counts.fetch(type)
    end

    def valid_type?(type)
      @counts.include? type
    end

    def record_query(*_unused, data)
      @counts[:queries] += 1
    end
  end
end
