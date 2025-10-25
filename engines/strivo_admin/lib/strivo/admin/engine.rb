module Strivo
  module Admin
    class Engine < ::Rails::Engine
      isolate_namespace Strivo::Admin
    end
  end
end
