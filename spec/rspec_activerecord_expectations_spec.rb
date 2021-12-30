require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations do
  let!(:album) { Album.create! }

  describe 'basic DSL' do
    it "requires you to specify a calculation" do
      expect_failure

      expect {}.to execute
    end

    it "requires you to specify a type of query" do
      expect_failure

      expect {}.to execute.less_than(3)
    end
  end

  describe "#fewer_than" do
    it "passes if you don't run many queries" do
      expect {
        3.times { album.reload }
      }.to execute.fewer_than(4).queries
    end

    it "errors if you run too many queries" do
      expect_failure

      expect {
        5.times { album.reload }
      }.to execute.fewer_than(4).queries
    end

    it "allows negation" do
      expect {
        3.times { album.reload }
      }.not_to execute.fewer_than(2).queries
    end

    it "is aliased to less_than" do
      expect {
        3.times { album.reload }
      }.to execute.less_than(4).queries
    end
  end
end
