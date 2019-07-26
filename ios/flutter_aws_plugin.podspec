#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_aws_plugin'
  s.version          = '0.0.1'
  s.summary          = 'AWS Plugin'
  s.description      = <<-DESC
AWS Plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'AWSMobileClient'
  s.dependency 'AWSCognito'
  s.dependency 'AWSCognitoIdentityProvider'
  s.dependency 'AWSPinpoint'

  s.ios.deployment_target = '10.0'
end

