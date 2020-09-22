Pod::Spec.new do |s|

  s.name                   = "BKPageControlView"
  s.version                = "2.2.0"
  s.summary                = "a simple page control view"
  s.homepage               = "https://github.com/MMDDZ/BKPageControlView"
  s.authors                = { "MMDDZ" => "694092596@qq.com" }
  s.license                = "MIT"
  s.source                 = { :git => 'https://github.com/MMDDZ/BKPageControlView.git', :tag => s.version.to_s }
  s.ios.deployment_target  = '9.0'
  s.source_files           = "BKPageControlView/Classes/*"
  s.public_header_files    = "BKPageControlView/Classes/*.h",
  s.frameworks             = 'Foundation', 'UIKit'
  
end
