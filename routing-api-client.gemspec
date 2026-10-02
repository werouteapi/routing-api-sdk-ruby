Gem::Specification.new do |spec|
  spec.name          = "routing-api-client"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  
  spec.summary       = "Official Ruby client for the Routing API"
  spec.description   = "Bank lookups, SWIFT codes, IBAN validation, OFAC screening, and Asia-Pacific account validation"
  spec.homepage      = "https://github.com/yourusername/routing-api-client-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"
  
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yourusername/routing-api-client-ruby"
  spec.metadata["bug_tracker_uri"] = "https://github.com/yourusername/routing-api-client-ruby/issues"
  
  spec.files = Dir.glob("{lib}/**/*") + ["README.md", "LICENSE"]
  spec.require_paths = ["lib"]
  
  spec.add_dependency "http", "~> 5.0"
  spec.add_dependency "json", "~> 2.6"
  
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.0"
end
