Pod::Spec.new do |s|
  s.name             = 'bluedot_point_sdk_push'
  s.version          = '2.2.0'
  s.summary          = 'Push notifications for the Bluedot Point SDK Flutter plugin.'
  s.description      = <<-DESC
    Push notification support for the Bluedot Point SDK Flutter plugin on iOS and Android.
  DESC
  s.homepage         = 'https://bluedot.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bluedot Innovation' => 'help@bluedot.io' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'BluedotPointSDK', '18.0.0'
  s.platform         = :ios, '15.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
