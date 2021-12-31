# RSpec Activerecord Expectations

Rspec::ActiveRecord::Expectations is a library for testing that your code
doesn't execute too many queries during execution. In development mode, it's
common to use gems like [bullet](https://github.com/flyerhzm/bullet), but no
similar functionality exists in RSpec.

Tests of this sort are useful when trying to write regression tests for code
that frequently has N+1s introduced accidentally by new feature development.

While it's possible to use
[Benchmark.measure](https://ruby-doc.org/stdlib-2.7.3/libdoc/benchmark/rdoc/Benchmark.html#method-c-measure)
to assert that runtime hasn't changed, tests typically run with a very small
number of records. This can make it difficult to ascertain whether new problems
have been introduced. That's because the natural variance in execution time for
queries takes over the majority of runtime, so benchmarked times are no longer
valid.

This gem introduces a number of new expectation types for your tests that
should make it easier to express the kinds of verification you're looking for.

## Setup

Setup is fairly straightforward. Add this gem to your `Gemfile` in the test
group.

```ruby
group 'test' do
  gem 'rspec-activerecord-expectations', '~> 1.0'
end
```

Then, include the functionality within your spec helper (or in a support file).

```ruby
RSpec.configure do |config|
  include RSpec::ActiveRecord::Expectations
end
```

That's it! Easy peasy.

## Basic Usage

At its core, `Rspec::ActiveRecord::Expectations` is just a series of new
matchers that you can apply to your tests. Let's take an example piece of app
functionality.

```ruby
class WastefulnessReport
  def perform
    (1..100).each do |n|
      ResourceType.find(n).summarize
    end
  end
end
```

This report obviously needs some refactoring. Let's add a test.

```ruby
# spec/reports/wastefulness_report_spec.rb

RSpec.describe WastefulnessReport do

  it "is reasonably efficient" do
    expect {
      WastefulnessReport.new.perform
    }.to execute.fewer_than(10).queries
  end

end
```

Running this example, we'll see a usefully failing test!

```ruby
Failures:

  1) WastefulnessReport is reasonably efficient
     Failure/Error:
       expect {
         WastefulnessReport.new.perform
       }.to execute.fewer_than(10).queries

       expected block to execute fewer than 10 queries, but it executed 100
     # ./spec/reports/wastefulness_report_spec.rb:30:in `block (2 levels) in <top (required)>'
```

That's it! Refactor your report to be more efficient and then leave the test in
place to make sure that future developers don't accidentally cause a
performance regression.

## Supported Matchers

Listed along with their aliases.

```ruby
expect {}.to execute.less_than(20).queries
expect {}.to execute.fewer_than(20).queries

expect {}.to execute.less_than_or_equal_to(20).queries
expect {}.to execute.at_most(20).queries

expect {}.to execute.greater_than(20).queries
expect {}.to execute.more_than(20).queries

expect {}.to execute.greater_than_or_equal_to(20).queries
expect {}.to execute.at_least(20).queries
```

You can use `query` instead of `queries` if it reads more nicely to you.

```ruby
expect {}.to execute.at_least(2).queries
expect {}.to execute.at_least(1).query
```

## Future Planned Functionality

This gem still has lots of future functionality. See below.

```ruby
expect {}.to execute.exactly(5).queries

expect {}.to execute.at_least(2).activerecord_queries
expect {}.to execute.at_least(2).insert_queries
expect {}.to execute.at_least(2).delete_queries
expect {}.to execute.at_least(2).load_queries
expect {}.to execute.at_least(2).schema_queries
expect {}.to execute.at_least(2).exists_queries
expect {}.to execute.at_least(2).queries_of_type("Audited::Audit Load")
expect {}.to execute.at_least(2).hand_rolled_queries

expect {}.not_to rollback_transaction.exactly(5).times
expect {}.not_to commit_transaction.once
expect {}.to run_a_transaction

expect {}.to create.exactly(5).of_type(User)
expect {}.to insert.exactly(5).subscription_changes
expect {}.to update.exactly(2).of_any_type
expect {}.to delete.exactly(2).of_any_type

expect {}.not_to repeatedly_load(Audited::Audit)
```

- ignore transactionals (begin / rollback)
- `name: Foo Load`
- differentiate AR queries from generic ones? arbitrary execution somehow?
- warn about warmup
- make sure we don't smite any built in methods (or from other libs)

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `rake spec` to run the tests.

Bug reports and PRs are welcome at
https://github.com/jmmastey/rspec-activerecord-expectations.

## Code of Conduct

Everyone interacting in the Rspec::Activerecord::Expectations project's
codebases, issue trackers, chat rooms and mailing lists is expected to follow
the [code of
conduct](https://github.com/jmmastey/rspec-activerecord-expectations/blob/master/CODE_OF_CONDUCT.md).

## Thanks

This gem was heavily patterned after
[shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers), a project
by Thoughtbot that has some seriously complex matchers. Thanks y'all.
