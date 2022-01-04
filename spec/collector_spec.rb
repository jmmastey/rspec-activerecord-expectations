require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations::Collector do
  subject!(:collector) { described_class.new }

  describe "#queries" do
    it "records anything" do
      album = Album.create!
      album.reload
      Album.find(album.id)

      expect(collector.queries_of_type(:queries)).to eq(3)
    end
  end

  describe "#insert_queries" do
    it "records basic object creations" do
      Album.create!

      album = Album.new
      album.save!

      expect(collector.queries_of_type(:insert_queries)).to eq(2)
    end

    it "can't include creates that fail validation at the ruby level" do
      Label.create

      expect(collector.queries_of_type(:insert_queries)).to eq(0)
    end

    it "includes creates that fail at the DB level" do
      begin
        label = Label.new
        label.save(validate: false)
      rescue ActiveRecord::NotNullViolation
        # NOOP
      end

      expect(collector.queries_of_type(:insert_queries)).to eq(1)
    end

    it "includes create statements chained from relations" do
      album = Album.create!
      album.tracks.create!

      expect(collector.queries_of_type(:insert_queries)).to eq(2)
    end
  end

  xdescribe "#delete_queries"
  xdescribe "#load_queries" # find_queries? does this include reload?
  xdescribe "#exists_queries"

  describe "#schema_queries" do
    it "tracks schema loading at the beginning of a test run, though that's not very useful" do
      expect {
        Label.reset_column_information
        Label.create
      }.to change {
        collector.queries_of_type(:schema_queries)
      }
    end
  end

  xdescribe "#queries_of_type"
  xdescribe "#hand_rolled_queries"
  xdescribe "#activerecord_queries"
end
