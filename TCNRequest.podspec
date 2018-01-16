#
# Be sure to run `pod lib lint TCNRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCNRequest'
  s.version          = '0.3.06'
  s.summary          = 'trueColor net base'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
公司内部iOS开发使用的网络基础库,包括各种不同形式的网络请求.
                       DESC

  s.homepage         = 'http://git.1kxun.com/ios/TCNRequest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '周高举' => 'zgj@shtruecolor.com' }
  s.source           = { :git => 'ssh://git@git.1kxun.com/ios/TCNRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.requires_arc = true

  s.frameworks = 'Foundation'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'TCNRequest/Classes/TCNRequest.h'
    core.dependency 'TCNRequest/AutoDataCenetr'
    core.dependency 'TCNRequest/RequestSerialization'
    core.dependency 'TCNRequest/ResponseSerialization'
  end

  s.subspec 'AutoDataCenetr' do |autoDataCenetr|
    autoDataCenetr.source_files = 'TCNRequest/Classes/AutoDataCenetr/**/*'
    autoDataCenetr.dependency 'AFNetworking', '~> 3.1.0'
    autoDataCenetr.dependency 'RegexKitLite', '~> 4.0'
    autoDataCenetr.dependency 'TCNDeviceInfo', '~> 0.0.03'
    autoDataCenetr.dependency 'TCNDataEncoding', '~> 0.0.5'
  end

  s.subspec 'RequestSerialization' do |requestSerialization|
    requestSerialization.source_files = 'TCNRequest/Classes/RequestSerialization/**/*'
    requestSerialization.dependency 'AFNetworking', '~> 3.1.0'
    requestSerialization.dependency 'TCNDeviceInfo', '~> 0.0.03'
    requestSerialization.dependency 'TCNDataEncoding', '~> 0.0.5'
  end

  s.subspec 'ResponseSerialization' do |responseSerialization|
    responseSerialization.source_files = 'TCNRequest/Classes/ResponseSerialization/**/*'
    responseSerialization.dependency 'AFNetworking', '~> 3.1.0'
  end
  
  # s.resource_bundles = {
  #   'TCNRequest' => ['TCNRequest/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
end
