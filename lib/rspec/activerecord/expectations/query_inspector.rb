module RSpec::ActiveRecord::Expectations
  class QueryInspector
    def self.valid_query_types
      [:queries, :schema_queries, :transaction_queries, :insert_queries]
    end

    def categorize(query)
      if query[:name] == "SCHEMA"
        [:schema_queries]
      elsif query[:name] == "TRANSACTION"
        [:transaction_queries]
      elsif query[:name] =~ /Create$/
        [:queries, :insert_queries]
      else
        [:queries]
      end
    end
  end
end
