# frozen_string_literal: true

module Spree
  module BaseHelperDecorator
    # voorbeeld: extra helpermethodes of overrides
    # def sample_helper(...)
    #   super
    # end
  end
end

Spree::BaseHelper.prepend(Spree::BaseHelperDecorator) if defined?(Spree::BaseHelper)
