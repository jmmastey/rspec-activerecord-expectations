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

  describe "query types" do
    it "allows you to specify all queries (singular or plural)" do
      expect {
        2.times { album.reload }
      }.to execute.at_least(2).queries

      expect {
        1.times { album.reload }
      }.to execute.at_least(1).query
    end
  end

  describe "#less_than" do
    it "passes if you don't run many queries" do
      expect {
        2.times { album.reload }
      }.to execute.less_than(3).queries
    end

    it "errors if you run too many queries" do
      expect_failure

      expect {
        4.times { album.reload }
      }.to execute.less_than(3).queries
    end

    it "allows negation" do
      expect {
        3.times { album.reload }
      }.not_to execute.less_than(2).queries
    end

    it "is aliased to fewer_than" do
      expect {
        2.times { album.reload }
      }.to execute.fewer_than(3).queries
    end
  end

  describe "#less_than_or_equal_to" do
    it "passes if you don't run many queries" do
      expect {
        2.times { album.reload }
      }.to execute.less_than_or_equal_to(3).queries

      expect {
        3.times { album.reload }
      }.to execute.less_than_or_equal_to(3).queries
    end

    it "errors if you run too many queries" do
      expect_failure

      expect {
        4.times { album.reload }
      }.to execute.less_than(3).queries
    end

    it "allows negation" do
      expect {
        4.times { album.reload }
      }.not_to execute.less_than(3).queries
    end

    it "is aliased to at_most" do
      expect {
        2.times { album.reload }
      }.to execute.fewer_than(3).queries
    end
  end

  describe "#greater_than" do
    it "passes if you run lots of queries" do
      expect {
        4.times { album.reload }
      }.to execute.greater_than(3).queries
    end

    it "errors if you don't run enough" do
      expect_failure

      expect {
        2.times { album.reload }
      }.to execute.greater_than(3).queries
    end

    it "allows negation" do
      expect {
        2.times { album.reload }
      }.not_to execute.greater_than(3).queries
    end

    it "is aliased to more_than" do
      expect {
        4.times { album.reload }
      }.to execute.more_than(3).queries
    end
  end

  describe "#greater_than_or_equal_to" do
    it "passes if you run lots of queries" do
      expect {
        4.times { album.reload }
      }.to execute.greater_than_or_equal_to(3).queries

      expect {
        3.times { album.reload }
      }.to execute.greater_than_or_equal_to(3).queries
    end

    it "errors if you run don't run enough queries" do
      expect_failure

      expect {
        2.times { album.reload }
      }.to execute.greater_than(3).queries
    end

    it "allows negation" do
      expect {
        2.times { album.reload }
      }.not_to execute.greater_than(3).queries
    end

    it "is aliased to at_least" do
      expect {
        4.times { album.reload }
      }.to execute.at_least(3).queries
    end
  end

  describe "#exactly" do
    it "passes if you run the right number of queries" do
      expect {
        2.times { album.reload }
      }.to execute.exactly(2).queries
    end

    it "errors if you execute too many queries" do
      expect_failure

      expect {
        3.times { album.reload }
      }.to execute.exactly(2).queries
    end

    it "errors if you execute not enough queries" do
      expect_failure

      expect {
        1.times { album.reload }
      }.to execute.exactly(2).queries
    end

    it "allows negation" do
      expect {
        3.times { album.reload }
      }.not_to execute.exactly(2).queries
    end
  end
end
