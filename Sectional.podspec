#
# Be sure to run `pod lib lint Sectional.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Sectional'
  s.version          = '0.1.0'
  s.summary          = 'Modular UICollectionView data sources.'

  s.description      = <<-DESC
Modular UICollectionView data sources.
                       DESC

  s.homepage         = 'https://github.com/chrislconover/Sectional'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chrislconover' => 'github@curiousapplications.com' }
  s.source           = { :git => 'https://github.com/chrislconover/Sectional.git', :tag => s.version.to_s }

  s.swift_version = '4.2'
  s.ios.deployment_target = '12.0'
  s.source_files = 'Sources/**/*'
  
  # s.resource_bundles = {
  #   'Sectional' => ['Sectional/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Differ', '~> 1.4'
  s.dependency 'RxSwift'
end
