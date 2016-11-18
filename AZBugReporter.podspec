Pod::Spec.new do |s|
  s.name         = "AZBugReporter"
  s.version      = "0.0.1"
  s.summary      = "iOS bug reporter."
  s.homepage     = "https://github.com/AndrewZhuCC/AZBugReporter"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Andrew" => "zaz92537@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/AndrewZhuCC/AZBugReporter.git", :tag => "#{s.version}" }
  s.source_files  = "Classes/**/*"
  s.requires_arc = true
end
