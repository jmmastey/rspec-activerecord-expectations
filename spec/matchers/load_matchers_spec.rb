require 'spec_helper'

RSpec.describe RSpec::ActiveRecord::Expectations::Matchers::LoadMatcher do
  let(:example) { Proc.new {} }
  let(:klass) { 'SomeKlass' }

  describe "#repeatedly_load" do
    it "has absolutely reasonable error output" do
      matcher = described_class.new('SomeKlass')

      matcher.matches?(example)

      expect(matcher.failure_message).to eq("expected block to repeatedly load #{klass}, but it was loaded 0 times")
      expect(matcher.failure_message_when_negated).to eq("expected block not to repeatedly load #{klass}, but it was loaded 0 times")
    end
  end
end
