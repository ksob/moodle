# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moodle/api/version'

Gem::Specification.new do |spec|
  spec.name          = 'moodle-api'
  spec.version       = Moodle::Api::VERSION
  spec.authors       = ['Ryan-Neal Mes']
  spec.email         = ['ryan.mes@gmail.com']

  spec.summary       = 'Moodle web service API wrapper.'
  spec.description   = 'Wraps Moodle API and exposes web services that have been made external.'
  spec.homepage      = 'https://github.com/get-smarter/moodle-api'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = ".DS_Store
.codeclimate.yml
.gitignore
.rspec
.rubocop.yml
.rubocop_todo.yml
.ruby-gemset
.ruby-version
.travis.yml
CHANGELOG.md
Gemfile
Guardfile
LICENSE.txt
README.md
Rakefile
________MOJE_ZMIANY.txt
bin/console
bin/setup
fixtures/vcr_cassettes/external_service/invalid_service.yml
fixtures/vcr_cassettes/external_service/token_service.yml
fixtures/vcr_cassettes/external_service/valid_service.yml
fixtures/vcr_cassettes/external_service/valid_service_empty_array_response.yml
fixtures/vcr_cassettes/external_service/valid_service_not_external.yml
fixtures/vcr_cassettes/external_service/valid_service_returning_null.yml
fixtures/vcr_cassettes/external_service/valid_service_with_invalid_token.yml
fixtures/vcr_cassettes/token_service/error_invalid_service_token_service.yml
fixtures/vcr_cassettes/token_service/invalid_password_token_service.yml
fixtures/vcr_cassettes/token_service/invalid_permissions_token_service.yml
fixtures/vcr_cassettes/token_service/invalid_service_token_service.yml
fixtures/vcr_cassettes/token_service/invalid_user_token_service.yml
fixtures/vcr_cassettes/token_service/invalid_username_token_service.yml
fixtures/vcr_cassettes/token_service/token_service.yml
lib/moodle.rb
lib/moodle/api.rb
lib/moodle/api/client.rb
lib/moodle/api/configuration.rb
lib/moodle/api/errors.rb
lib/moodle/api/request.rb
lib/moodle/api/token_generator.rb
lib/moodle/api/version.rb
moodle-api.gemspec"

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'

  spec.add_dependency 'rest-client'
end
