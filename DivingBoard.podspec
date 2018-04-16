Pod::Spec.new do |s|
  s.name         = "DivingBoard"
  s.version      = "1.0.2"
  s.summary      = "An iOS framework that provides an interface for browsing and searching for photos from Unsplash.com."
  s.description  = <<-DESC
  DivingBoard is similar to a UIImagePickerController, but for retrieving photos from Unsplash instead of the camera roll. It uses the Unsplash API and requires an Unsplash app ID, which you can sign up for on their website.
                   DESC
  s.homepage     = "https://github.com/jim-rhoades/DivingBoard"
  s.screenshots  = "https://camo.githubusercontent.com/44d087d5f10319cdb68630c02390f8dd97488b1e/687474703a2f2f6372757368617070732e636f6d2f646976696e67626f6172642f696d672f646976696e67626f6172642e6a7067"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jim Rhoades" => "jim@crushapps.com" }
  s.social_media_url   = "https://twitter.com/crushapps"
  s.platform     = :ios, "11.2"
  s.source       = { :git => "https://github.com/jim-rhoades/DivingBoard.git", :tag => "v#{s.version}" }
  s.source_files  = "DivingBoard/**/*.{swift}"
  s.resources = "DivingBoard/**/*.{xcassets,storyboard}"
  s.exclude_files = "ExampleApp"
end
