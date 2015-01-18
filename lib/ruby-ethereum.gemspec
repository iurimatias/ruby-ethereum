# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
#require "ruby-ethereum/version"

Gem::Specification.new do |s|
  s.name        = "ruby-ethereum"
  #s.version     = RubyEthereum::VERSION
  s.version     = "0.0.1"
  s.authors     = ["Iuri Matias", "Anthony Laibe"]
  s.email       = ["iuri.matias@gmail.com", "anthony@laibe.cc"]
  s.homepage    = "https://github.com/iurimatias/ruby-ethereum"
  s.summary     = %q{}
  s.description = %q{}

  s.rubyforge_project = "ruby-ethereum"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"

end
