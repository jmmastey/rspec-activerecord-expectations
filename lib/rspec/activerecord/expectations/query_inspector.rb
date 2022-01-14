module RSpec::ActiveRecord::Expectations
  class QueryInspector
    def self.valid_query_types
      [:queries, :schema_queries, :insert_queries, :load_queries,
       :destroy_queries, :exists_queries,
       :transaction_queries, :commit_queries, :rollback_queries]
    end

    def categorize(query)
      if query[:name] == "SCHEMA"
        [:schema_queries]
      elsif query[:sql] =~ /^commit/i
        [:commit_queries]
      elsif query[:sql] =~ /^rollback/i
        [:rollback_queries]
      elsif query[:name] == "TRANSACTION"
        [:transaction_queries]
      elsif query[:name] =~ /Create$/
        [:queries, :insert_queries]
      elsif query[:name] =~ /Load$/
        [:queries, :load_queries]
      elsif query[:name] =~ /Destroy$/
        [:queries, :destroy_queries]
      elsif query[:name] =~ /Delete All$/
        [:queries, :destroy_queries]
      elsif query[:name] =~ /Exists\??$/
        [:queries, :exists_queries]
      else
        [:queries]
      end
    end
  end
end
