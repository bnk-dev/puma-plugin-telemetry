# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in puma-plugin-telemetry.gemspec
gemspec

# Allow CI to pin a specific Puma version for the test matrix, e.g.
# PUMA_VERSION='~> 8.0'. Defaults to the gemspec constraint when unset.
puma_version = ENV.fetch('PUMA_VERSION', nil)
gem 'puma', puma_version if puma_version

gem 'dogstatsd-ruby'

gem 'rack'
gem 'rake', '~> 13.2'
gem 'rspec', '~> 3.13'
gem 'rubocop', '~> 1.75.5'
gem 'rubocop-performance', '~> 1.25'
