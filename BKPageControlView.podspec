Pod::Spec.new do |s|

s.name             = 'BKPageControlView'
s.version          = '2.1.1'
s.summary          = 'a simple page control view'
s.homepage         = 'https://github.com/MMDDZ/BKPageControlView'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'MMDDZ' => '694092596@qq.com' }
s.source           = { :git => 'https://github.com/MMDDZ/BKPageControlView.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'

s.source_files = 'BKPageControlView/*.{h,m}', 'BKPageControlView/BgScrollView/*.{h,m}', 'BKPageControlView/Menu/*.{h,m}', 'BKPageControlView/Extension/*.{h,m}'
s.public_header_files = 'BKPageControlView/BKPageControlView.h', 'BKPageControlView/BKPageControlViewController.h', 'BKPageControlView/BgScrollView/*.h', 'BKPageControlView/Menu/*.h', 'BKPageControlView/Extension/UIViewController+BKPageControlView.h'
s.private_header_files = 'BKPageControlView/BKPCViewKVOChildControllerPModel.h',  'BKPageControlView/Extension/NSAttributedString+BKPageControlView.h', 'BKPageControlView/Extension/NSString+BKPageControlView.h', 'BKPageControlView/Extension/UIView+BKPageControlView.h'

s.framework  = "UIKit"

end
