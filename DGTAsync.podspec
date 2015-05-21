Pod::Spec.new do |s|
  s.name         = "DGTAsync"
  s.version      = "1.0.1"
  s.summary      = "DGTAsync utilities for Swift"
  s.description  = <<-DESC
                   DGTAsync was inspired by duemunk/Async. But it was written from the ground up to be able to handle an async tasks such as Alamofire download/upload tasks
                   DESC
  s.homepage     = "https://github.com/0angelic0/DGTAsync"
  s.license      = "MIT"
  s.author             = { "0angelic0" => "pisit@digitopolisstudio.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/0angelic0/DGTAsync.git", :tag => "1.0.1" }
  s.source_files  = "DGTAsync"
  s.requires_arc = true
end
