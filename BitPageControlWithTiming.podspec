Pod::Spec.new do |spec|

  spec.name         = "BitPageControlWithTiming"
  spec.version      = "0.0.1"
  spec.summary      = "A custom PageControl with fill progress animation written in Swift"

  spec.description  = <<-DESC
  A custom PageControl with fill progress animation, with automatic and manual options and customizable UI.
                   DESC

  spec.homepage     = "https://github.com/Sjahriyar/BitPageControl"
  spec.screenshots  = "https://raw.githubusercontent.com/Sjahriyar/BitPageControl/master/BitPageControl-screenshot.gif"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Shahriyar" => "sh.soheytizadeh@gmail.com" }
  spec.social_media_url   = "https://www.linkedin.com/in/shahriyar-s-01"

  spec.ios.deployment_target = "12.0"
  spec.swift_version = "4.2"
  
  spec.source       = { :git => "https://github.com/Sjahriyar/BitPageControl.git", :tag => "#{spec.version}" }

  spec.source_files  = "BitPageControl/**/*.{h,m,swift}"

end
