require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations::Matchers::QueryCountMatcher do
  let(:example) { Proc.new {} }

  describe "#fewer_than" do
    it "has some lovely error output" do
      matcher = described_class.new.fewer_than(3).queries

      matcher.matches?(example)

      expect(matcher.failure_message).to eq("expected block to execute fewer than 3 queries, but it executed 0")
      expect(matcher.failure_message_when_negated).to eq("expected block not to execute fewer than 3 queries, but it executed 0")
    end
  end
end
