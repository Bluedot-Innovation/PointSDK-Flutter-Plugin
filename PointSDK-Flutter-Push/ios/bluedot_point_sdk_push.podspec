Pod::Spec.new do |s|
  s.name             = 'bluedot_point_sdk_push'
  s.version          = '2.1.2'
  s.summary          = 'Optional push notifications module for the Bluedot Point SDK Flutter plugin (Android only).'
  s.description      = <<-DESC
    Optional push notifications module for the Bluedot Point SDK Flutter plugin.
    Push notification support is Android-only; this podspec provides the required
    no-op iOS stub so the package can be included in cross-platform Flutter projects.
  DESC
  s.homepage         = 'https://bluedot.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bluedot Innovation' => 'help@bluedot.io' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '14.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end

