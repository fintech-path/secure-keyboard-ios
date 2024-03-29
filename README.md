# HCSecurityKeyboard
[![version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](https://bintray.com/geyifeng/maven/immersionbar) [![author](https://img.shields.io/badge/author-hcxc-orange.svg)](https://github.com/gyf-dev) [![swift](https://img.shields.io/badge/swift-5.0-red.svg)](https://github.com/gyf-dev)
### [中文说明](README_CN.md)
## About
This library provides a secure keyboard.

Various types of information theft attacks based on keyboard input data are very common. Including mobile finance, e-commerce, third-party payment, online games, social software and other apps, there are various links of user information leakage. A large number of sensitive data such as account numbers, passwords, mobile phone numbers, credit card numbers, bank card numbers, ID numbers, home address information, company address information, family member information, personal private information, and business information are entered into the mobile Internet through the App keyboard. Hackers decompile these popular applications and bundle and embed keyboard hooks (monitoring programs) in them to monitor and steal various data entered by users through the keyboard.


## Effect Picture
<img src="docs/img/example.png" alt="example" style="zoom:50%;" />

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate HCSecurityKeyboard into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'HCSecurityKeyboard'
```

## Documentation 
### How to use
   ```swift
   let keyboardView = SRTKeyboardView()
   keyboardView.title = "安全键盘"
   keyboardView.titleBackgroundColor = .gray
   keyboardView.titleColor = .black
   
   keyboardView.observeTextChanged = {
      print("监听文字改变")
   }
   /* 
   randomKeys
   false: Use the default keyboard format 
   true: random keyboard is used for each initialization
   */
   keyboardView.randomKeys = true
   // Limit the number of inputs
   keyboardView.textLimited = 5
   textField.delegate = self
   // Try to leave this sentence to the end, because this is when the component is initialized
   keyboardView.textInput = textField
   ```


## Remind

- ARC
- iOS>=9.0
- iPhone \ iPad screen anyway

## License

HCSecurityKeyboard is available under the Apache 2.0 license. See the LICENSE file for more info.

