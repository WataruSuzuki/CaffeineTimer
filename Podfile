platform :ios,'9.3'
use_frameworks!

target "CaffeineTimer" do

  pod 'DJKFlatIconAuthors', :git => 'https://github.com/WataruSuzuki/DJKFlatIconAuthors.git'
  pod 'LMGaugeView'
  pod 'DJKPurchaseService', :git => 'https://github.com/WataruSuzuki/PurchaseService-iOS.git'
  pod 'GoogleMobileAdsMediationNend'
  pod 'MaterialComponents'

  target 'CaffeineTimerTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

# target "TodayWidget" do
#   # inherit! :search_paths
#   # pod 'SwiftExtensionChimera'
#   pod 'KeychainAccess'
# end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-CaffeineTimer/Pods-CaffeineTimer-acknowledgements.plist', 'CaffeineTimer/Settings.bundle/Pods-acknowledgements.plist')
end
