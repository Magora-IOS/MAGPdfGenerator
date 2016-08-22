Pod::Spec.new do |s|
  s.name             = 'MAGPdfGenerator'
  s.version          = '0.1.2'
  s.summary          = 'An utility to convert UIView to a PDF document.'
  s.description      = <<-DESC
MAGPdfGenerator is an utility which provides the ability to convert UIView's representation to a PDF document. The UIView may be created from XIB file and use Autolayouts that makes a convenient way to draw the pdf's content.
                       DESC
  s.homepage         = 'https://github.com/Magora-IOS/MAGPdfGenerator'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Konstantin Mamaev' => 'mamaev@magora-systems.com' }
  s.source           = { :git => 'https://github.com/Magora-IOS/MAGPdfGenerator.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MAGPdfGenerator/Classes/**/*'
  s.public_header_files = 'MAGPdfGenerator/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
