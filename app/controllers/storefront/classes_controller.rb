# frozen_string_literal: true

module Storefront
  class ClassesController < BaseController
    def index
      @class_types = ClassType.includes(:sessions).order(:name)
    end
  end
end
