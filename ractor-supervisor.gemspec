# frozen_string_literal: true

require_relative 'lib/ractor/supervisor/version'

Gem::Specification.new do |spec|
  spec.name          = 'ractor-supervisor'
  spec.version       = Ractor::Supervisor::VERSION
  spec.authors       = ['Marc-Andre Lafortune']
  spec.email         = ['github@marc-andre.ca']

  spec.summary       = 'Supervisors for Ractor.'
  spec.description   = 'Supervisors for Ractor.'
  spec.homepage      = 'https://github.com/marcandre/ractor-supervisor'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/marcandre/ractor-supervisor'
  spec.metadata['changelog_uri'] = 'https://github.com/marcandre/ractor-supervisor/blob/master/Changelog.md'

  spec.add_dependency 'require_relative_dir'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
