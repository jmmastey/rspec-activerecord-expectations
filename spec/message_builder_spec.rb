require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations::MessageBuilder do
  def message_for(matcher, actual:)
    allow(matcher).to receive(:actual_count).and_return(actual)
    described_class.new(matcher).failure_message
  end

  def negated_message_for(matcher, actual:)
    allow(matcher).to receive(:actual_count).and_return(actual)
    described_class.new(matcher).failure_message_when_negated
  end

  it "uses a matcher object to generate messages" do
    matcher = Matchers::QueryCountMatcher.new.exactly(1).query

    instance = described_class.new(matcher)

    expect(instance.failure_message).to be_a(String)
    expect(instance.failure_message_when_negated).to be_a(String)
  end

  describe "query counts" do
    let(:matcher) { Matchers::QueryCountMatcher.new }

    it "specializes output by query type" do
      matcher.exactly(2)

      expect(message_for(matcher.queries, actual: 3)).to match(/queries/)
      expect(message_for(matcher.schema_queries, actual: 3)).to match(/schema queries/)
      expect(message_for(matcher.insert_queries, actual: 3)).to match(/insert queries/)
      expect(message_for(matcher.load_queries, actual: 3)).to match(/load queries/)
      expect(message_for(matcher.exists_queries, actual: 3)).to match(/exists queries/)
      expect(message_for(matcher.transaction_queries, actual: 3)).to match(/transaction queries/)
    end

    it "singularizes where appropriate" do
      matcher.exactly(1)

      expect(message_for(matcher.query, actual: 3)).to match(/query/)
      expect(message_for(matcher.schema_query, actual: 3)).to match(/schema query/)
      expect(message_for(matcher.insert_query, actual: 3)).to match(/insert query/)
      expect(message_for(matcher.load_query, actual: 3)).to match(/load query/)
      expect(message_for(matcher.exists_query, actual: 3)).to match(/exists query/)
      expect(message_for(matcher.transaction_query, actual: 3)).to match(/transaction query/)
    end

    describe "exact matches" do
      it "has plural messages" do
        matcher.exactly(2).queries

        expect(message_for(matcher, actual: 3)).to eq(
          "expected block to execute 2 queries, but it executed 3"
        )

        expect(negated_message_for(matcher, actual: 2)).to eq(
          "expected block not to execute 2 queries, but it did so"
        )
      end

      it "has singular-specific messages" do
        matcher.exactly(1).query

        expect(message_for(matcher, actual: 3)).to eq(
          "expected block to execute a query, but it executed 3"
        )

        expect(negated_message_for(matcher, actual: 1)).to eq(
          "expected block not to execute a query, but it did so"
        )
      end
    end

    describe "other comparison types" do
      it "handles gt" do
        matcher.greater_than(2).queries

        expect(message_for(matcher, actual: 1)).to eq(
          "expected block to execute more than 2 queries, but it executed 1"
        )

        expect(negated_message_for(matcher, actual: 3)).to eq(
          "expected block not to execute more than 2 queries, but it executed 3"
        )
      end

      it "handles gteq" do
        matcher.greater_than_or_equal_to(2).queries

        expect(message_for(matcher, actual: 1)).to eq(
          "expected block to execute at least 2 queries, but it executed 1"
        )

        expect(negated_message_for(matcher, actual: 3)).to eq(
          "expected block not to execute at least 2 queries, but it executed 3"
        )
      end

      it "handles lt" do
        matcher.less_than(2).queries

        expect(message_for(matcher, actual: 3)).to eq(
          "expected block to execute less than 2 queries, but it executed 3"
        )

        expect(negated_message_for(matcher, actual: 0)).to eq(
          "expected block not to execute less than 2 queries, but it executed 0"
        )
      end

      it "handles lteq" do
        matcher.less_than_or_equal_to(2).queries

        expect(message_for(matcher, actual: 3)).to eq(
          "expected block to execute at most 2 queries, but it executed 3"
        )

        expect(negated_message_for(matcher, actual: 3)).to eq(
          "expected block not to execute at most 2 queries, but it executed 3"
        )
      end
    end
  end

  xdescribe "transactions" do
  end
end
