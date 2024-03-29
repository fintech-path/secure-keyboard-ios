Pod::Spec.new do |s|
  s.name     = 'HCSecurityKeyboard'
  s.version  = '1.2.0'
  s.swift_versions = ['5.3', '5.4', '5.5']
  s.license  = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.summary  = 'homecredit security keyboard framework.'
  s.homepage = 'https://github.com/hccxc/secure-keyboard-ios'
  s.authors  = { 'hcxc' => 'hcc_app@homecredit.cn' }
  s.source   = { :git => 'https://github.com/hccxc/secure-keyboard-ios', :tag => s.version, :submodules => true }
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.resource_bundle = {
       'HCSecurityKeyboard' => ['Resource/*.png']
    }
  s.source_files = 'HCSecurityKeyboard/*.{h,m,mm,swift}'
  s.dependency "SnapKit", "~> 4.2.0"
end
