require File.expand_path('../../../lib/hashie/extensions/ruby_version', __FILE__)

# Generates the bundle command for running an integration test
#
# @param [String] integration the integration folder to run
# @param [String] command the command to run
# @return [String]
def integration_command(integration, command)
  if Hashie::Extensions::RubyVersion.new(RUBY_VERSION) >=
     Hashie::Extensions::RubyVersion.new('3.1.0')
     ruby_opts = "RUBYOPT=--disable-error_highlight "
  end

  "#{ruby_opts} #{command}"
end

# Generates the Gemfile for an integration
#
# @param [String] integration the integration test name
# @return [String]
def integration_gemfile(integration)
  "BUNDLE_GEMFILE=#{integration_path(integration)}/Gemfile"
end

# Generates the path to the integration
#
# @param [String] integration the integration test name
# @return [String]
def integration_path(integration)
  "spec/integration/#{integration}"
end

# Runs all integration specs in their own environment
def run_all_integration_specs(handler: ->(_code) {}, logger: ->(_msg) {})
  logger.call(%(Running "activesupport" integration spec))
  system(integration_command("activesupport", "bundle exec rspec spec/integration/activesupport_spec.rb"))
  handler.call($CHILD_STATUS&.exitstatus || 0)

  logger.call(%(Running "elasticsearch" integration spec))
  system(integration_command("elasticsearch", "bundle exec rspec spec/integration/elasticsearch_spec.rb"))
  handler.call($CHILD_STATUS&.exitstatus || 0)

  # Dir['spec/integration/*']
  #   .map { |directory| directory.split('/').last }
  #   .each do |integration|
  #     logger.call(%(Running "#{integration}" integration spec))
  #     system(integration_command(integration, "bundle exec rspec #{integration_path(integration)}"))
  #     handler.call($CHILD_STATUS.exitstatus)
  #   end
end
