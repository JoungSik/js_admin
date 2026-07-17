require_relative "lib/js_admin/version"

Gem::Specification.new do |spec|
  spec.name        = "js_admin"
  spec.version     = JSAdmin::VERSION
  spec.authors     = [ "JoungSik" ]
  spec.email       = [ "tjstlr2010@gmail.com" ]
  spec.homepage    = "https://github.com/JoungSik/js_admin"
  spec.summary     = "Zero-configuration CRUD engine for Rails applications."
  spec.description = "JSAdmin exposes Active Record models through a generic CRUD UI built with Tailwind CSS and Hotwire."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3", "< 9.0"
  spec.add_dependency "importmap-rails", ">= 2.0", "< 3.0"
  spec.add_dependency "stimulus-rails", ">= 1.3.4", "< 2.0"
  spec.add_dependency "tailwindcss-rails", ">= 4.4.0", "< 5.0"
  spec.add_dependency "turbo-rails", ">= 2.0.23", "< 3.0"
end
