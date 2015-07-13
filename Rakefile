$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'rotp-motion'
  app.archs['iPhoneSimulator'] = ['x86_64']
#  app.archs['iPhoneSimulator'] = ['i386']

  app.vendor_project('vendor/otp_generator', :static)
  app.frameworks << 'Security'
end
