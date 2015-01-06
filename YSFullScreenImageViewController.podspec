Pod::Spec.new do |s|
  s.name = 'YSFullScreenImageViewController'
  s.version = '0.0.10'
  s.summary = 'Full screen image view controller.'
  s.homepage = 'https://github.com/yusuga/YSFullScreenImageViewController'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.source = { :git => 'https://github.com/yusuga/YSFullScreenImageViewController.git', :tag => s.version.to_s }
    s.platform = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.source_files = 'Classes/YSFullScreenImageViewController/*.{h,m}'
  
  s.dependency 'CocoaLumberjack', '~> 2.0.0-rc'
  
  s.prefix_header_contents = "#import <CocoaLumberjack/CocoaLumberjack.h>
#ifdef DEBUG
    static const DDLogLevel ddLogLevel = DDLogLevelAll;
#else
    static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif"
end