# Trailblazer::Future
[![Build Status](https://travis-ci.org/trailblazer/trailblazer-future.svg)](https://travis-ci.org/trailblazer/trailblazer-future)
[![Gem Version](https://badge.fury.io/rb/trailblazer-future.svg)](http://badge.fury.io/rb/trailblazer-future)

## Installation

- Step 1

Update `trailblazer` to it latest patch version `~> 2.0.7`

- Step 2

Test your build and remove any deprecation warning

- Optional step (recommended)

Feed a homeless person

- Step 3

Add this line to your application's Gemfile:

```ruby
gem 'trailblazer-future'
```

## Usage

1) Inherit operation from `Trailblazer::V2_1::Operation`
```ruby
class MyOP < Trailblazer::V2_1::Operation
end
```
2) Migrate to TRB 2.1 following the [migration path](http://trailblazer.to/api-docs/#trailblazer-migration-path), here a quick summary of the breaking changes:
    - new API using keyword arguments: `MyOP.(params)` -> `MyOp.(params: params)` (more [here](http://trailblazer.to/api-docs/#operation-call))
    - using `symbol` instead of `string` for `:model` and `:current_user`: `result['model']` -> `result[:model]`
    - Replace `Railway::Right/Left` with `Trailblazer::Activity::Right/Left`
    - Add option `fast_track: true` for the steps that uses `pass_fast!` or `fail_fast!` (check the new [wiring API](http://trailblazer.to/api-docs/#activity-wiring-api))
    - Nested macro now gets the all result object so use `:input` and `:output` to filter data in/out

## Notes

1) Operations of different versions cannot be nested
2) Rails controller's `run` is for V2.0. Use `run_v21` for the migrated operations

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
