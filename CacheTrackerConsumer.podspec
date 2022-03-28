Pod::Spec.new do |s|
    s.name = 'CacheTrackerConsumer'
    s.version = '1.7.0'
    s.summary = 'Helper classes to connect UI and CacheTracker (https://github.com/ladeiko/CacheTracker)'
    s.homepage = 'https://github.com/ladeiko/CacheTrackerConsumer'
    s.license = { :type => 'CUSTOM', :file => 'LICENSE' }
    s.author = { 'Siarhei Ladzeika' => 'sergey.ladeiko@gmail.com' }
    s.platform = :ios, '9.0'
    s.source = { :git => 'https://github.com/ladeiko/CacheTrackerConsumer.git', :tag => "#{s.version}" }
    s.requires_arc = true
    s.default_subspec = 'Core'
    s.swift_versions = ['4.0', '4.2', '5.0', '5.1', '5.3', '5.5']

    s.subspec 'Core' do |s|
        s.source_files = 'Classes/Core/**/*.{swift}'
        s.dependency 'CacheTracker'
    end

    s.subspec 'UIKit' do |s|
        s.source_files = [ 'Classes/Core/**/*.{swift}', 'Classes/UIKit/**/*.{swift,h}' ]
        s.frameworks = 'UIKit'
        s.dependency 'CacheTracker'
    end

end
