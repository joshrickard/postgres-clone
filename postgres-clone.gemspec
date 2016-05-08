# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postgres/clone/version'

Gem::Specification.new do |spec|
  spec.name          = 'postgres-clone'
  spec.version       = Postgres::Clone::VERSION
  spec.authors       = ['Josh Rickard']
  spec.email         = ['josh.rickard@gmail.com']

  spec.summary       = 'A command line utility for copying postgres databases.'
  spec.description   = 'A command line utility for copying postgres databases.  Wraps pg_backup and pg_restore in a Ruby wrapper.'
  spec.homepage      = 'https://github.com/joshrickard/postgres-clone'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = 'pg-clone'
  spec.require_paths = ['lib']

  spec.add_dependency 'highline', '~> 1.7.8'
  spec.add_dependency 'net-ssh', '~> 3.1.1'
  spec.add_dependency 'rainbow', '~> 2.1.0'
  spec.add_dependency 'thor', '~> 0.19.1'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
