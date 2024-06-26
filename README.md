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
  gem 'rspec-activerecord-expectations', '~> 3.0'
end
```

Then, include the functionality within your `rails_helper.rb` (or in a support
file).

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

## Preventing Repeated Load (N+1) Queries

Reloading, whether by e.g. `Album.find` or `album.tracks` are both antipatterns
within your code. They will load from the database for every iteration in a
loop, unless you load records outside the loop, cache responses, or use an
eager loading mechanism like `includes`. These sorts of queries are often
referred to as N+1 queries.

This sort of query can be prevented using the `repeatedly_load` expectation.

```ruby
expect {}.not_to repeatedly_load('SomeActiveRecordClass')
```

This matcher will track ActiveRecord's built in load methods to prevent those
N+1 situations. Using eager loading (e.g. `Track.all.includes(:album)`) will
allow these expectations to pass as expected!

### Testing Batch Queries

If your code loads records in batches, it may be more difficult to create
expectations for repeated loading. After all, each batch will execute its own
queries, which may look like repeated loading.

If your test has a small enough number of records that only one batch is
loaded, your tests may work just fine. But otherwise, you may want to allow
your code to specify a batch size in order to guarantee only a single batch
is loaded.

```ruby
tracks = Track.all

expect {
  TrackSerializer.perform(tracks, batch_size: tracks.count)
}.not_to repeatedly_load('Track')
```

## Counting Queries

Some services won't necessarily have N+1 issues with records loading, but might
still have problems with executing too many queries. In this case, the
`repeatedly_load` matcher might be insufficient.

In this case, consider creating an expectation on the total number of queries
executed by your code. Several comparison types are available, along with some
aliases to allow for easier to read tests.

```ruby
expect {}.to execute.less_than(20).queries
expect {}.to execute.fewer_than(20).queries

expect {}.to execute.less_than_or_equal_to(20).queries
expect {}.to execute.at_most(20).queries

expect {}.to execute.greater_than(20).queries
expect {}.to execute.more_than(20).queries

expect {}.to execute.greater_than_or_equal_to(20).queries
expect {}.to execute.at_least(20).queries

expect {}.to execute.exactly(20).queries

expect {}.to execute.at_least(2).queries
expect {}.to execute.at_least(1).query # singular form also accepted
```

### Specific Query Types

You can make assertions for the total number of queries executed, but sometimes
it's more valuable to assert that a particular _type_ of query was executed.
For example, a particular number of queries to destroy records. There are
matchers available for that purpose as well!

```ruby
expect {}.to execute.exactly(20).queries

expect {}.to execute.exactly(20).insert_queries
expect {}.to execute.exactly(20).load_queries
expect {}.to execute.exactly(20).destroy_queries
expect {}.to execute.exactly(20).exists_queries

expect {}.to execute.exactly(20).schema_queries
expect {}.to execute.exactly(20).transaction_queries
```

**Note:** Transaction (for example, `ROLLBACK`) queries are not counted in any of these
categories, nor are queries that load the DB schema.

**Note:** Destroy and delete queries are both condensed into the matcher for
the errorthe error  `destroy_queries`.

## Transaction Management

Sometimes, it makes sense to monitor whether database transactions were
successful or not. This is very similar to using `expect{}.to change(SomeModel,
:count)` in a spec, but nonetheless it can be useful to assert transactions
themselves. Some assertions are available for this purpose.

```ruby
expect {}.to execute_a_transaction
expect {}.to rollback_a_transaction
expect {}.to roll_back_a_transaction
expect {}.to commit_a_transaction
```

A complication to this scheme is that Rails tries not to make unnecessary database
calls, which means that attempting to save a model that has failing validations
won't actually attempt to save to the database.

```ruby
expect {
  MyClass.create!(required_field: nil)
}.to rollback_a_transaction
```

This assertion will fail, as `create!` will never make it as far as the
database.  That said, if you manually create a transaction, _and you select
data within that transaction_, you may assert a rollback.

```ruby
expect {
  MyClass.first # triggers the transaction
  MyClass.create!(required_field: nil)
}.to rollback_a_transaction
```

It you need to make transaction-related assertions of this sort, your best bet
may be to assert that a commit statement was _not_ issued.

```ruby
expect do
  MyClass.create!(required_field: nil)
rescue
  # NOOP
end.not_to rollback_a_transaction
```

Note that ActiveRecord will not only roll back the transaction, but also
re-raise errors. As such, it's necessary in this example to rescue that error,
otherwise the test would fail simply because the code caused a `raise`.

### Counting Transactions

Similar to counting queries, you can quantify the number of transactions you
expect to succeed / fail. This is probably of limited value in all but some
very specific cases.

```ruby
expect {}.to commit_a_transaction.once
expect {}.to rollback_a_transaction.exactly(5).times
expect {}.to commit_a_transaction.at_least(5).times
```

## Future Planned Functionality

This gem still has lots of future functionality. See below.

```ruby
expect {}.to execute.at_least(2).queries_of_type("Audited::Audit Load")
expect {}.to execute.at_least(2).load_queries("Audited::Audit")

expect {}.to execute.at_least(2).activerecord_queries
expect {}.to execute.at_least(2).hand_rolled_queries

expect {}.to create.exactly(5).of_type(User)
expect {}.to insert.exactly(5).subscription_changes
expect {}.to update.exactly(2).of_any_type
expect {}.to delete.exactly(2).of_any_type
```

- warn if we smite any built in methods (or methods from other libs)
- support Rails 6 bulk insert (still one query)

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
