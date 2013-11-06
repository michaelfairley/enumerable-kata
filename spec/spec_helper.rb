require "bundler/setup"
require "my_enumerable"
require "timeout"

ENUMERABLE_CLASS = MyEnumerable
ENUMERATOR_CLASS = Enumerator


TEST_RUBY_VERSION = "1.9"
def ruby_version_is(version, &blk)
  matches = case version
            when Range
              version.cover?(TEST_RUBY_VERSION)
            when String
              TEST_RUBY_VERSION >= version
            else; raise
            end
  yield  if matches
end

def ruby_bug(number, version, &blk)
  ruby_version_is(version, &blk)
end

def quarantine!(&blk)
end

require "helpers/scratch"

SpecTimeoutError = Class.new(StandardError)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'default'
  config.fail_fast = true

  config.around(:each) do
    |example| Timeout::timeout(0.1, SpecTimeoutError) { example.run }
  end
end
