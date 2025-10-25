require_relative "lib/strivo/admin/version"

Gem::Specification.new do |spec|
  spec.name          = "strivo_admin"
  spec.version       = Strivo::Admin::VERSION
  spec.authors       = ["Strivo"]
  spec.email         = ["dev@strivo.example"]

  spec.summary       = "Strivo admin engine"
  spec.description   = "Internal admin interface for Strivo"
  spec.homepage      = "https://example.com"
  spec.license       = "MIT"
  spec.require_paths = ["lib"]

  spec.files = Dir.chdir(File.expand_path("..", __dir__)) do
    Dir["engines/strivo_admin/{app,config,db,lib}/**/*",
        "engines/strivo_admin/MIT-LICENSE",
        "engines/strivo_admin/README.md"]
  end

  spec.add_development_dependency "rspec-rails"
end
