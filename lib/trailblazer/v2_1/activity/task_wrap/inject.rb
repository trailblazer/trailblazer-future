class Trailblazer::V2_1::Activity
  module TaskWrap
    # Allows to inject attributes for a task and defaults them if not.
    # Per default, the defaulting is scoped, meaning only the task will see it.
    module Inject
      module Defaults
        module_function

        def Extension(defaults)
          # Returns new ctx.
          input  = ->((original_ctx, flow_options), circuit_options) do
            defaulted_options = defaults_for(defaults, original_ctx)

            ctx = original_ctx.merge(defaulted_options)

            Trailblazer::V2_1::Context(ctx, {}, flow_options[:context_options])
          end

          output = ->(new_ctx, (original_ctx, _flow_options), _circuit_options) { # FIXME: use Unscope
            _, mutable_data = new_ctx.decompose

            # we are only interested in the {mutable_data} part since the disposed part
            # represents the injected/defaulted data.
            original_ctx.merge(mutable_data)
          }

          VariableMapping::Extension(input, output, id: input)
        end

        # go through all defaultable options and default them if appropriate.
        def defaults_for(defaults, original_ctx)
          Hash[
            defaults.collect { |k, v| [k, original_ctx[k] || v] } # FIXME: doesn't allow {false/nil} currently.
          ]
        end
      end
    end # Inject
  end
end
