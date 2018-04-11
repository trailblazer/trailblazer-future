# TODO: mark/make all but mutable_options as frozen.
# The idea of Skill is to have a generic, ordered read/write interface that
# collects mutable runtime-computed data while providing access to compile-time
# information.
# The runtime-data takes precedence over the class data.
#
# notes
# a context is a ContainerChain with two elements (when reading)
module Trailblazer::V2_1
  # Holds local options (aka `mutable_options`) and "original" options from the "outer"
  # activity (aka wrapped_options).

  # only public creator: Build
  class Context # :data object:
    def initialize(wrapped_options, mutable_options)
      @wrapped_options, @mutable_options = wrapped_options, mutable_options
      # TODO: wrapped_options should be optimized for lookups here since it could also be a Context instance, but should be a ContainerChain.
    end

    def [](name)
      # ContainerChain.find( [@mutable_options, @wrapped_options], name )

      # in 99.9% or cases @mutable_options will be a Hash, and these are already optimized for lookups.
      # it's up to the ContainerChain to optimize itself.
      return @mutable_options[name] if @mutable_options.key?(name)
      @wrapped_options[name]
    end

    # TODO: use ContainerChain.find here for a generic optimization
    #
    # the version here is about 4x faster for now.
    def key?(name)
      # ContainerChain.find( [@mutable_options, @wrapped_options], name )
      @mutable_options.key?(name) || @wrapped_options.key?(name)
    end

    def []=(name, value)
      @mutable_options[name] = value
    end

    # @private
    #
    # This method might be removed.
    def merge(hash)
      original, mutable_options = decompose

      ctx = Trailblazer::V2_1::Context( original, mutable_options.merge(hash) )
    end

    # Return the Context's two components. Used when computing the new output for
    # the next activity.
    def decompose
      [ @wrapped_options, @mutable_options ]
    end

    def keys
      @mutable_options.keys + @wrapped_options.keys # FIXME.
    end



    # TODO: maybe we shouldn't allow to_hash from context?
    # TODO: massive performance bottleneck. also, we could already "know" here what keys the
    # transformation wants.
    # FIXME: ToKeywordArguments()
    def to_hash
      {}.tap do |hash|
        # the "key" here is to call to_hash on all containers.
        [ @wrapped_options.to_hash, @mutable_options.to_hash ].each do |options|
          options.each { |k, v| hash[k.to_sym] = v }
        end
      end
    end
  end

  def self.Context(wrapped_options, mutable_options={})
    Context.new(wrapped_options, mutable_options)
  end
end # Trailblazer::V2_1
