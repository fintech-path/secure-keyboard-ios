Pod::Spec.new do |s|
  s.name     = 'HCSecurityKeyboard'
  s.version  = '0.0.1'
  s.license  = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.summary  = 'homecredit security keyboard framework.'
  s.homepage = 'https://github.com/homecreditchina/secure-keyboard-ios'
  s.authors  = { 'Chace Wang' => 'Chace.Wang@homecredit.cn' }
  s.source   = { :git => 'https://github.com/homecreditchina/secure-keyboard-ios', :tag => s.version, :submodules => true }
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.resource_bundle = {
       'HCSecurityKeyboard' => ['Resource/*.png']
    }
  s.source_files = 'HCSecurityKeyboard/*.{h,m,mm,swift}'
  s.dependency "SnapKit", "~> 4.2.0"
end
