# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','ios-cert-enrollment.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'ios-cert-enrollment'
  s.version = "0.0.8"
  s.author = 'Nolan Brown'
  s.email = 'nolanbrown@gmail.com'
  s.homepage = 'https://github.com/nolanbrown/ios-cert-enrollment'
  s.platform = Gem::Platform::RUBY
  s.summary = 'SCEP server for iOS Configuration Profiles'
  s.description = 'Easy tools to implement a SCEP server for iOS Configuration Profiles'
# Add your other files here if you make them
  s.files = %w(
lib/ios-cert-enrollment.rb
lib/ios-cert-enrollment/certificate.rb
lib/ios-cert-enrollment/configuration.rb
lib/ios-cert-enrollment/device.rb
lib/ios-cert-enrollment/profile.rb
lib/ios-cert-enrollment/sign.rb
lib/ios-cert-enrollment/ssl.rb
lib/ios-cert-enrollment/version.rb
  )
  s.require_paths << 'lib'
  s.rdoc_options << '--title' << 'iOS Configuration Profiles' << '--main' #<< 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_runtime_dependency('uuidtools')
  s.add_runtime_dependency('plist')
end
