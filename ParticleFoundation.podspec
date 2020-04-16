Pod::Spec.new do |spec|
  spec.name                  = 'ParticleFoundation'
  spec.version               = '0.9.4'
  spec.summary               = 'Particle\'s Swift Foundation.'
  spec.description           = 'Adds bases for commonly used objects in.'
  spec.homepage              = 'https://github.com/ParticleApps/Foundation'
  spec.license               = { :type => 'MIT' , :file => 'LICENSE'}
  spec.author                = { 'Rocco Del Priore' => 'rocco@particleapps.co' }
  spec.source                = { :git => 'https://github.com/ParticleApps/Foundation.git', :tag => "#{spec.version}" }
  spec.social_media_url      = 'https://twitter.com/ParticleAppsCo'
  spec.frameworks            = 'Foundation', 'UIKit'
  spec.ios.deployment_target = '10.0'
  spec.source_files          = "ParticleFoundation", "ParticleFoundation/**/*.{swift,h,m}"
  spec.swift_version         = '4.2'
end
