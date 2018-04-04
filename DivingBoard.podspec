Pod::Spec.new do |s|
  s.name         = "DivingBoard"
  s.version      = "1.1.0"
  s.summary      = "An iOS framework that provides an interface for browsing and searching for photos from Unsplash.com"
  s.homepage     = "https://github.com/jim-rhoades/DivingBoard"
  s.screenshots  = "https://camo.githubusercontent.com/44d087d5f10319cdb68630c02390f8dd97488b1e/687474703a2f2f6372757368617070732e636f6d2f646976696e67626f6172642f696d672f646976696e67626f6172642e6a7067"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Jim Rhoades" => "jim@crushapps.com" }
  s.source       = { :git => "https://github.com/jim-rhoades/DivingBoard.git", :tag => "#{s.version}" }
  s.platform     = :ios, '10.0'
  s.source_files = 'DivingBoard/**/*.{swift}'
  s.frameworks   = 'UIKit', 'Foundation'
  s.requires_arc = true
end
