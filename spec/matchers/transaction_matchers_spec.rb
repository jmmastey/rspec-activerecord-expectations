require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations::Matchers::TransactionMatcher do
  it "uses the phrase builder to generate output" do
    matcher = described_class.new(:transaction_queries).twice

    expect(matcher.failure_message).to eq(
      "expected block to execute 2 transactions, but it didn't execute any"
    )
  end
end
