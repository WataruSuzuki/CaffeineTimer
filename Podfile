platform :ios,'9.3'
use_frameworks!

target "CaffeineTimer" do

  pod 'DJKUtilities', :git => 'https://github.com/WataruSuzuki/DJKUtilities.git'
  pod 'DJKFlatIconAuthors', :git => 'https://github.com/WataruSuzuki/DJKFlatIconAuthors.git'
  pod 'LMGaugeView'
  pod 'DJKUtilAdMob', :git => 'https://github.com/WataruSuzuki/DJKUtilAdMob.git'
  pod 'GoogleMobileAdsMediationNend'
  pod 'MaterialComponents'

  target 'CaffeineTimerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CaffeineTimerUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target "TodayWidget" do
  #use_frameworks!
  inherit! :search_paths
  pod 'DJKUtilities', :git => 'https://github.com/WataruSuzuki/DJKUtilities.git'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-CaffeineTimer/Pods-CaffeineTimer-acknowledgements.plist', 'CaffeineTimer/Settings.bundle/Pods-acknowledgements.plist')
end
