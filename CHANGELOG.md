# Changelog
 
## [3.0.0] - 2024-06-21
- Add support for rails 7.x
- Dropped support for ruby 2.x

## [2.3.0] - 2022-01-29
- Add quantifiers to transaction matchers
- Add much more complicated English output for readable matchers
- Update README for the same

## [2.2.0] - 2022-01-14
- Adds transaction matcher to verify that code was executed within a
  transaction at minimum
- Transaction matcher also allows for commits and rollbacks
- Update README for accompanying functionality

## [2.1.1] - 2022-01-12
- Gemspec is really generated using the version of ruby that's locally in use.
  Update that build artifact to use non-java dependencies.

## [2.1.0] - 2022-01-12
- Change CI matrix for more version compatibility
- Update gemspec to move some deps into development only
- README changes

## [2.0.0] - 2022-01-07
- Require much more recent ruby, to use syntax that's been around since 2017

## [1.3.0] - 2021-12-31
- Add `repeatedly_load` matcher
- Add query type matchers for `load_queries`, `schema_queries`, `transaction_queries`, `destroy_queries`
- Allow singular version of all query types (e.g. `transaction_queries` vs `transaction_query`)
- Fix failure message for `execute.exactly` matcher

## [1.2.0] - 2021-12-31
- Add `query` as a synonym for `queries`
- Ignore schema and transaction queries in query count
- Add beginning of recording specific query types
- Add query count matcher for `exactly`

## [1.1.0] - 2021-12-30
- Add query count matchers for e.g. `less_than_or_equal_to`, `greater_than`

## [1.0.1] - 2021-12-30
- Pin all the dependencies to a proper working subset
- Expand testing to many rails / ruby combinations

## [1.0.0] - 2021-12-30
- Basic gem w/ all the fixins and README and such
- Add `less_than` comparison, and `queries` type
- Basic tests in place, and not bad tbh
 
