Pod::Spec.new do |s|

s.name             = 'BKPageControlView'
s.version          = '2.0.4'
s.summary          = 'a simple page control view'
s.homepage         = 'https://github.com/MMDDZ/BKPageControlView'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'MMDDZ' => '694092596@qq.com' }
s.source           = { :git => 'https://github.com/MMDDZ/BKPageControlView.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'

s.source_files = 'BKPageControlView/*.{h,m}', 'BKPageControlView/Menu/*.{h,m}', 'BKPageControlView/Extension/*.{h,m}'
s.public_header_files = 'BKPageControlView/BKPageControlView.h', 'BKPageControlView/BKPageControlViewController.h', 'BKPageControlView/Menu/*.h'
s.private_header_files = 'BKPageControlView/BKPageControlKVOModel.h', 'BKPageControlView/Extension/*.h'

s.framework  = "UIKit"

end
