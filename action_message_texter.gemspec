$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'action_message_texter/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'action_message_texter'
  spec.version     = ActionMessageTexter::VERSION
  spec.authors     = ['Arthur Li']
  spec.email       = ['z22919456@gmail.com']
  spec.homepage    = 'http://github.com/z22919456/action_message_texter'
  spec.summary     = 'SMS/Text Message gem, allow your Rails send short message to phone'
  spec.description = 'SMS/Text Message gem, allow your Rails send short message to phone'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 5.0.0'
end
