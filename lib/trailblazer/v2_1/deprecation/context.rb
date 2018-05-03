module Trailblazer::V2_1
  module Deprecation
    class ContextWithIndifferentAccess < Trailblazer::V2_1::Context
      def [](key)
        return super unless Trailblazer::V2_1::Operation::PublicCall.deprecatable?(key)
        key, _ = Trailblazer::V2_1::Operation::PublicCall.deprecate_string(key, nil)
        super(key)
      end

      def []=(key, value)
        return super unless Trailblazer::V2_1::Operation::PublicCall.deprecatable?(key)
        key, _ = Trailblazer::V2_1::Operation::PublicCall.deprecate_string(key, nil)
        super(key, value)
      end
    end
  end
end

Trailblazer::V2_1::Operation::PublicCall.module_eval do
  def self.options_for_public_call(options={}, *containers)
    hash_transformer = ->(containers) { containers[0].to_hash } # FIXME: don't transform any containers into kw args.

    options = deprecate_strings(options)

    immutable_options = Trailblazer::V2_1::Context::ContainerChain.new( [options, *containers], to_hash: hash_transformer ) # Runtime options, immutable.

    Trailblazer::V2_1::Deprecation::ContextWithIndifferentAccess.new(immutable_options, {})
  end

  def self.deprecatable?(key)
    key.is_a?(String) && key.split(".").size == 1
  end

  def self.deprecate_strings(options)
    ary = options.collect { |k,v| deprecatable?(k) ? deprecate_string(k, v) : [k,v]  }
    Hash[ary]
  end

  def self.deprecate_string(key, value)
    warn "[Trailblazer::V2_1] Using a string key for non-namespaced keys is deprecated. Please use `:#{key}` instead of `#{key.inspect}`."
    [ key.to_sym, value ]
  end
end
