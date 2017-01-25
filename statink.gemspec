# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'statink/version'

Gem::Specification.new do |spec|
  spec.name          = "statink"
  spec.version       = Statink::VERSION
  spec.authors       = ["KID the Euforia"]
  spec.email         = ["kid0725@gmail.com"]

  spec.summary       = "gem for stat.ink API"
  spec.description   = "gem for stat.ink API"
  spec.homepage      = "https://github.com/blueberrystream/link-url-setter-for-statink"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-stack_explorer"

  spec.add_dependency "dotenv"
  spec.add_dependency "thor"
end
