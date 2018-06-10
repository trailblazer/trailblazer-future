module Trailblazer::V2_1::Rails::Controller::Cell
  private

  module Render
    def render_v2_1(cell = nil, options = {}, *, &block)
      return super unless cell.kind_of?(::Cell::ViewModel)
      render_v2_1_cell(cell, options)
    end

    def render_v2_1_cell(cell, options)
      options = options.reverse_merge(layout: true)

      # render_v2_1 the cell.
      content = cell.()

      render_v2_1({ html: content }.merge(options))
    end
  end

  include Render
end
