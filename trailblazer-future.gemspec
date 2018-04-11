
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "trailblazer/future/version"

Gem::Specification.new do |spec|
  spec.name          = "trailblazer-future"
  spec.version       = Trailblazer::Future::VERSION
  spec.authors       = ["Abdelkader Boudih"]
  spec.email         = ["terminale@gmail.com"]

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/trailblazer/trailblazer-future"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end
  spec.require_paths = ["lib"]

  # Legacy gems
  spec.add_dependency "trailblazer", "~> 2.0.7"

  spec.add_development_dependency "minitest", "~> 5.0"
  # For activity gem
  spec.add_dependency "hirb"

  spec.post_install_message = "\e[33m[Warning]\e[0m Trailblazer Future is an upgrade helper gem only. Upgrade your operations and use Trailblazer 2.1 directly"
end
