#
# Be sure to run `pod lib lint CodeField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CodeField'
  s.version          = '0.2.0'
  s.summary          = 'Custom UITextField to input code.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
CodeField is custom view extends UIView. Using CodeField you can type the code like secret codes.
                       DESC

  s.homepage         = 'https://github.com/brownsoo/CodeField'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brownsoo' => 'hansune@me.com' }
  s.source           = { :git => 'https://github.com/brownsoo/CodeField.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files     = 'Sources/**/*.swift'
  s.swift_versions = ['4.0', '4.2', '5.0']
  s.frameworks = 'UIKit'
end
