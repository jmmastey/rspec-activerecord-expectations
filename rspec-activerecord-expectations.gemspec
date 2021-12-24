Gem::Specification.new do |spec|
  spec.name          = "rspec-activerecord-expectations"
  spec.version       = '0.0.1'
  spec.authors       = ["Joseph Mastey"]
  spec.email         = ["hello@joemastey.com"]

  spec.summary       = %q{A gem to test how many activerecord queries your code executes.}
  spec.description   = %q{A gem to test how many activerecord queries your code executes.}
  spec.homepage      = "https://github.com/jmmastey/rspec-activerecord-expectations"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/jmmastey/rspec-activerecord-expectations/blob/master/CHANGELOG.md"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
