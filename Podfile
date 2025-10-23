# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'VPNApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VPNApp
pod 'lottie-ios'
pod 'Google-Mobile-Ads-SDK'

end

target 'VPNTunnel' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VPNTunnel
pod 'OpenVPNAdapter', :git => 'https://github.com/ss-abramchuk/OpenVPNAdapter.git', :tag => '0.4.0'

end
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
