lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "trailblazer/future/version"

Gem::Specification.new do |spec|
  spec.name          = "trailblazer-future"
  spec.version       = Trailblazer::Future::VERSION
  spec.authors       = ["Abdelkader Boudih"]
  spec.email         = ["terminale@gmail.com"]

  spec.summary       = "Use Trailblazer 2.0 and 2.1 in one application"
  spec.homepage      = "https://github.com/trailblazer/trailblazer-future"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  # Legacy gems
  spec.add_dependency "trailblazer", "~> 2.0.7"
  spec.add_dependency "hirb"

  spec.add_development_dependency "minitest", "~> 5.0"

  spec.post_install_message = "\e[33m[Warning]\e[0m Trailblazer Future is an upgrade helper gem only. Upgrade your operations and use Trailblazer 2.1 directly"
end
