require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations::Matchers::QueryCountMatcher do
  it "uses the phrase builder to generate output" do
    matcher = described_class.new.more_than(3).insert_queries

    expect(matcher.failure_message).to eq("expected block to execute more than 3 insert queries, but it didn't execute any")
  end
end
