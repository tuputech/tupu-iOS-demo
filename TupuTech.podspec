#
# Be sure to run `pod lib lint TupuTech.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TupuTech'
  s.version          = '1.0.4'
  s.summary            = '专注于图像识别基于深度学习的图像识别技术多维度解读图片和视频'

  s.description      = 'Guangzhou Tupu tech image and video SDK which is by Deeplearning!'

  s.homepage         = 'https://www.tuputech.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cosmos180' => 'jinxinhou@tuputech.com' }
  s.source           = { :git => 'https://git.coding.net/BugHero/TupuTech.git', :tag => s.version.to_s } 
  s.ios.deployment_target = '8.0'

  s.vendored_frameworks = ['TupuTech/InnerFrameworks/tuputechSDK.framework']

  s.source_files = 'TupuTech/Classes/**/*'

  s.frameworks = "AVFoundation", "Accelerate", "OpenGLES", "Foundation", "CoreGraphics", "CoreMedia", "AssetsLibrary"
  s.dependency 'GPUImage'
  #s.dependency 'OpenCV'
end
