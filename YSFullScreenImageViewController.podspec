Pod::Spec.new do |s|
  s.name = 'YSFullScreenImageViewController'
  s.version = '0.0.12'
  s.summary = 'Full screen image view controller.'
  s.homepage = 'https://github.com/yusuga/YSFullScreenImageViewController'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.source = { :git => 'https://github.com/yusuga/YSFullScreenImageViewController.git', :tag => s.version.to_s }
    s.platform = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.source_files = 'Classes/YSFullScreenImageViewController/*.{h,m}'
end