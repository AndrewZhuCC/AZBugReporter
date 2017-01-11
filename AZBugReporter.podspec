Pod::Spec.new do |s|
  s.name         = "AZBugReporter"
  s.version      = "0.1.4"
  s.summary      = "iOS bug reporter."
  s.homepage     = "https://github.com/AndrewZhuCC/AZBugReporter"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Andrew" => "zaz92537@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/AndrewZhuCC/AZBugReporter.git", :tag => "#{s.version}" }
  s.source_files  = "Classes/**/*"
  s.requires_arc = true

  s.frameworks = 'Photos'

  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'UITableView+FDTemplateLayoutCell', '~> 1.5.beta'
  s.dependency 'Masonry', '~> 1.0.0'
  s.dependency 'IQKeyboardManager', '~> 4.0.0'
  s.dependency 'MBProgressHUD', '~> 0.9.0'
  s.dependency 'Mantle', '~> 2.0.0'
  s.dependency 'SAMKeychain'
  s.dependency 'SDWebImage'
  s.dependency 'AZMWPhotoBrowser', '~> 2.1.3'
  s.dependency 'AZ-THPerformanceMonitor', '~> 0.0.16'
  s.dependency 'MJRefresh'
  s.dependency 'AZNetworkEye', '~> 1.0.8'

end
