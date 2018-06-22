# Trailblazer::Future
Master: [![Build Status](https://travis-ci.org/trailblazer/trailblazer-future.svg)](https://travis-ci.org/trailblazer/trailblazer-future)

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

- Inherit or migrate operations to `Trailblazer::V2_1::Operation`
- Fix tests and code with the API, using `params:` and `[:model]`
- Improve code using new `wiring API`

## Notes

1) Operations of different versions cannot be nested
2) Rails controller's `run` is for V2.0. Use `run_v21` for the migrated operations

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).