$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "elastic_ar_sync/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "elastic_ar_sync"
  spec.version     = ElasticArSync::VERSION
  spec.authors     = ["KitakatsuTed"]
  spec.email       = ["travy300637@gmail.com"]
  spec.homepage      = "https://github.com/KitakatsuTed/elastic_ar_sync"
  spec.summary       = %q{easy setup elasticsearch for ActiveRecord}
  spec.description   = %q{This gem has useful methods to sync rdb data with es data.}
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.1.0"

  spec.add_development_dependency "sqlite3"
end
