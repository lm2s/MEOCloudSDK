#
# Be sure to run `pod lib lint MEOCloudSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MEOCloudSDK"
  s.version          = "0.1.0"
  s.summary          = "An iOS framework for using MEOCloud API in a simple and easy way."
  # s.description      = <<-DESC
  #                     An optional longer description of MEOCloudSDK
  #
  #                     * Markdown format.
  #                     * Don't worry about the indent, we strip it!
  #                     DESC
  s.homepage         = "https://github.com/lm2s/MEOCloudSDK"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Luís M. Marques Silva" => "lm2s@gmx.com" }
  s.source           = { :git => "https://github.com/lm2s/MEOCloudSDK.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/_lm2s'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  #s.public_header_files = 'MEOCloudSDK/*.h'
  s.source_files = 'MEOCloudSDK/*.{h,m}', 'MEOCloudSDK/Model/*.{h,m}', 'MEOCloudSDK/AFDownloadRequestOperation/*.{h,m}'

  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.5'
  s.dependency "BDBOAuth1Manager", "~> 1.5.0"
end