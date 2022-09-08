#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bluedot_point_sdk.podspec` to validate before publishing.

Pod::Spec.new do |s|
  s.name             = 'bluedot_point_sdk'
  s.version          = '1.0.0'
  s.summary          = 'Bluedot Point SDK for Flutter'
  s.description      = <<-DESC
                        Bluedot Point SDK for Flutter
                       DESC
  s.homepage         = 'https://github.com/Bluedot-Innovation/PointSDK-iOS'
  s.license          = { :type => "Copyright",
                        :text => <<-LICENSE
                                     Point SDK
                                     Created by Bluedot Innovation in 2018.
                                     Copyright © 2022 Bluedot Innovation. All rights reserved.
                                     By downloading or using the Bluedot Point SDK for iOS, You agree to the Bluedot Terms and Conditions
                                     https://bluedot.io/agreements/#terms and Privacy Policy https://bluedot.io/agreements/#privacy
                                     and Billing Policy https://bluedot.io/agreements/#billing
                                     and acknowledge that such terms govern Your use of and access to the iOS SDK.
                                     LICENSE
                        }
  s.author           = { 'Bluedot Innovation' => 'https://www.bluedot.io' }
  s.source           = { :git => 'https://github.com/Bluedot-Innovation/PointSDK-Flutter-Plugin' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'BluedotPointSDK', '15.6.4'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
  s.swift_version = '5.0'
end
