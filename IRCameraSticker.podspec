Pod::Spec.new do |spec|
  spec.name         = "IRCameraSticker"
  spec.version      = "1.0.0"
  spec.summary      = "Make a Button Group to control."
  spec.description  = "Make a Button Group to control."
  spec.homepage     = "https://github.com/irons163/IRCameraSticker.git"
  spec.license      = "MIT"
  spec.author       = "irons163"
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/irons163/IRCameraSticker.git", :tag => spec.version.to_s }
  spec.source_files  = "IRCameraSticker/Classes/**/*.{h,m,xib}"
  spec.resources = ["IRCameraSticker/**/*.xcassets", "IRCameraSticker/**/*.bundle"]
  spec.dependency "GPUImage"
end
