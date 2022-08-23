/*
 * Copyright 2007-2022 Home Credit Xinchi Consulting Co. Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SnapKit
import UIKit

private let numericKeysPool: [SRTKeyItem] = [
    .alpha1, .alpha2, .alpha3, .alpha4, .alpha5, .alpha6, .alpha7, .alpha8, .alpha9, .symbol17, .alpha0,
]

private let alphaCantainsNumericKeysPool: [SRTKeyItem] = [
    .alpha1, .alpha2, .alpha3, .alpha4, .alpha5, .alpha6, .alpha7, .alpha8, .alpha9, .alpha0,
]

private let alphaKeysPool: [SRTKeyItem] = [
    .alphaQ, .alphaW, .alphaE, .alphaR, .alphaT, .alphaY, .alphaU, .alphaI, .alphaO, .alphaP,
    .alphaA, .alphaS, .alphaD, .alphaF, .alphaG, .alphaH, .alphaJ, .alphaK, .alphaL,
    .alphaZ, .alphaX, .alphaC, .alphaV, .alphaB, .alphaN, .alphaM,
]

private let symbolKeysPool: [SRTKeyItem] = [
    .symbol1, .symbol2, .symbol3, .symbol4, .symbol5, .symbol6, .symbol7, .symbol8, .symbol9, .symbol10,
    .symbol11, .symbol12, .symbol13, .symbol14, .symbol15, .symbol16, .symbol17, .symbol18, .symbol19, .symbol20,
    .symbol21, .symbol22, .symbol23, .symbol24, .symbol25, .symbol26, .symbol27, .symbol28, .symbol29, .symbol30,
    .symbol31, .symbol32
]

// Initialization time should be after viewSafeAreaInsetsDidChange
public class SRTKeyboardView: UIInputView {
    private static let keyboardHeight: Double = 196
    private static let titleHeight: Double = 44
    private static var bottomPadding: Double {
        if #available(iOS 15.0, *) {
            let window = UIApplication.shared.connectedScenes
                            .map({$0 as? UIWindowScene})
                            .compactMap({$0})
                            .first?.windows
                            .filter({$0.isKeyWindow}).first
            return Double(window?.safeAreaInsets.bottom ?? 0.0)
        } else {
            let window = UIApplication.shared.windows.first
            if #available(iOS 11.0, *) {
                return Double(window?.safeAreaInsets.bottom ?? 0.0)
            } else {
                return Double(window?.frame.maxY ?? 0.0)
            }
        }
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superview != nil ?
            NotificationCenter.default.addObserver(self, selector: #selector(userDidTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil) :
            NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        if #available(iOS 11.0, *) {
            self.superview != nil ?
                NotificationCenter.default.addObserver(self, selector: #selector(capturedDidChange), name: UIScreen.capturedDidChangeNotification, object: nil) :
                NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
            if UIScreen.main.isCaptured, self.superview != nil {
                capturedDidChange()
            }
        }
    }

    @objc
    private func userDidTakeScreenshot() {
    }

    @objc
    private func capturedDidChange() {
    }

    // MARK: - Properties

    public weak var textInput: UITextField? {
        didSet {
            textInput?.inputView = self
            reset()
            updateTextInput()
        }
    }

    public var textLimited = 6
    public var decryptedText: String {
        return plainText
    }

    public var title: String? {
        get {
            return accessoryTitleLabel.text
        }
        set {
            accessoryTitleLabel.text = newValue
        }
    }

    public var titleColor: UIColor? {
        get {
            return accessoryTitleLabel.textColor
        }
        set {
            accessoryTitleLabel.textColor = newValue
        }
    }

    public var titleBackgroundColor: UIColor? {
        get {
            return accessoryView.backgroundColor
        }
        set {
            accessoryView.backgroundColor = newValue
        }
    }

    public var randomKeys = false
    public var observeTextChanged: (() -> Void)?

    // MARK: - UI controls

    private weak var accessoryView: UIView!
    private weak var kyeboardContainer: UIView!
    private weak var accessoryTitleLabel: UILabel!
    private weak var finishButton: UIButton!
    private weak var changeKeyBoardTypeButton: UIButton!
    // MARK: - Private properties
    private var keyboardType: SRTKeyBoardType = .alphaAndNumeric
    
    private var marginLeading = 5.0
    private let marginTop = 5.0
    private let buttonCountLine1 = 10
    private let buttonCountLine2 = 10
    private var buttonCountLine3: Int {
        return keyboardType == .alphaAndNumeric ? 9 : 10
    }
    private var buttonCountLine4: Int {
        return keyboardType == .alphaAndNumeric ? 7 : 2
    }
    private let buttonLines = 4
    private let numericButtonCount = 3
    private var buttons: [SRTKeyboardButton] = []
    private var functionButtons: [UIButton] = []
    private var buttonSize = CGSize(width: 30, height: 45)
    private var numericButtonSize = CGSize(width: (UIScreen.main.bounds.width - 10 - 10) / 3, height: 45)
    private var functionButtonSize = CGSize(width: 50, height: 45)
    private var marginHorizontalBetweenButtons = 0.0
    private var numericMarginHorizontalBetweenButtons = 5.0
    private var marginVerticalBetweenButtons = 0.0
    private var firstAlphaPosition: [CGPoint] = []

    private var keyScheme: [[SRTKeyItem]] = []
    private var textStore: [UInt8] = []
    private var encodeOffet: UInt8 = 0

    private var doingFastCancal: Bool = false
    // MARK: - Lifecycle
    // Initialization time should be after viewSafeAreaInsetsDidChange
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: SRTKeyboardView.keyboardHeight + SRTKeyboardView.titleHeight + SRTKeyboardView.bottomPadding), inputViewStyle: .keyboard)
        setupButtons()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Publid methods

    func reset() {
        textStore = []
        encodeOffet = UInt8(arc4random() % 6) + 3
        textInput?.text = ""
        for button in buttons {
            button.removeFromSuperview()
        }
        for functionButton in functionButtons {
            functionButton.removeFromSuperview()
        }

        buttons.removeAll()
        functionButtons.removeAll()
        resetKeyScheme()
        for line in 0 ..< buttonLines {
            createButton(for: line)
        }
        createFunctionButtons()
        observeTextChanged?()
    }

    // MARK: - Private methods

    private func setupButtons() {
        setUIParameters()
    }

    private func updateTextInput() {
        guard let textInput = textInput else { return }
        for button in buttons {
            button.textInput = textInput
        }
    }
    
    private func setKeyBoardView() {
        resetUIParameters()
        for button in buttons {
            button.removeFromSuperview()
        }
        for functionButton in functionButtons {
            functionButton.removeFromSuperview()
        }

        buttons.removeAll()
        functionButtons.removeAll()
        resetKeyScheme()
        for line in 0 ..< buttonLines {
            createButton(for: line)
        }
        createFunctionButtons()
    }

    @objc
    private func tapFunctionButton(_ sender: UIButton) {
        switch sender.tag {
        case SRTFunctionKeyType.capsLock.rawValue:
            overturnKeys()
        case SRTFunctionKeyType.backspace.rawValue:
            insertBackspace()
        case SRTFunctionKeyType.space.rawValue:
            insertSpace()
        default:
            break
        }
    }

    @objc
    private func tapFinishButton(_ sender: UIButton) {
        textInput?.resignFirstResponder()
    }
    
    @objc
    private func tapChangeSymbolOrAlphaButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if keyboardType == .alphaAndNumeric {
            keyboardType = .symbol
        } else {
            keyboardType = .alphaAndNumeric
        }
        setKeyBoardView()
    }

    @objc
    private func tapChangeNumericOrAlphaButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if keyboardType == .numeric {
            keyboardType = .alphaAndNumeric
        } else {
            keyboardType = .numeric
        }
        setKeyBoardView()
    }

    @objc
    private func deleteLongPressFunction(_ action: UILongPressGestureRecognizer) {
        if action.state == .ended {
            doingFastCancal = false
        } else {
            doingFastCancal = true
        }
        DispatchQueue.global().async {
            while self.doingFastCancal {
                Thread.sleep(forTimeInterval: 0.1)
                DispatchQueue.main.async {
                    if (self.textInput?.text?.count ?? 0) > 0 && self.doingFastCancal {
                        self.insertBackspace()
                    }
                }
            }
        }
    }

    private func keys(for row: Int) -> [SRTKeyItem] {
        guard row < keyScheme.count else { return [] }

        return keyScheme[row]
    }

    private func overturnKeys() {
        var lowcase = true
        for button in buttons {
            if let keyItem = SRTKeyItem(rawValue: button.input.lowercased()) {
                if case SRTKeyItemType.alpha = keyItem.itemType {
                    if button.input.uppercased() == button.input {
                        lowcase = false
                        button.input = button.input.lowercased()
                    } else {
                        button.input = button.input.uppercased()
                    }
                }
            }
        }

        if let capsLockButton = functionButtons.first(where: { $0.tag == SRTFunctionKeyType.capsLock.rawValue }) {
            capsLockButton.backgroundColor = lowcase ?  #colorLiteral(red: 0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1) :  #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
    }

    private func insertSpace() {
        guard let textField = textInput else { return }

        let currentText: String = textField.text ?? ""
        let shouldInsertText = currentText.count < textLimited

        if shouldInsertText {
            let textBox: SRTSecurityTextBox = self
            // in security mode, only support append, insert and replace is denied
            textField.text = "\(textField.text ?? "")*"
            textBox.append(" ")
        }
    }

    private func insertBackspace() {
        guard let textField = textInput,
              let text = textField.text,
              !text.isEmpty else { return }

        let newString = String(text[..<text.index(before: text.endIndex)])
        textField.text = newString
        removeLast()
    }
}

// MARK: - Data functions

extension SRTKeyboardView {
    private func resetKeyScheme() {
        switch keyboardType {
        case .alphaAndNumeric:
            var pool = randomKeys ? alphaCantainsNumericKeysPool.sorted { _, _ -> Bool in
                arc4random() < arc4random()
            } : alphaCantainsNumericKeysPool
            let line1 = pool
            pool = randomKeys ? alphaKeysPool.sorted { _, _ -> Bool in
                arc4random() < arc4random()
            } : alphaKeysPool
            let line2 = Array(pool[0 ..< buttonCountLine2])
            let line3 = Array(pool[buttonCountLine2 ..< (buttonCountLine2 + buttonCountLine3)])
            let line4 = Array(pool[(buttonCountLine2 + buttonCountLine3)...])
            keyScheme = [line1, line2, line3, line4]
        case .symbol:
            let pool = randomKeys ? symbolKeysPool.sorted { _, _ -> Bool in
                arc4random() < arc4random()
            } : symbolKeysPool
            let line1 = Array(pool[0 ..< buttonCountLine1])
            let line2 = Array(pool[buttonCountLine1 ..< (buttonCountLine1 + buttonCountLine2)])
            let line3 = Array(pool[(buttonCountLine1 + buttonCountLine2) ..< (buttonCountLine1 + buttonCountLine2 + buttonCountLine3)])
            let line4 = Array(pool[(buttonCountLine1 + buttonCountLine2 + buttonCountLine3)...])
            keyScheme = [line1, line2, line3, line4]
        case .numeric:
            let pool = randomKeys ? numericKeysPool.sorted { _, _ -> Bool in
                arc4random() < arc4random()
            } : numericKeysPool
            let line1 = Array(pool[0 ..< 3])
            let line2 = Array(pool[3 ..< 6])
            let line3 = Array(pool[6 ..< 9])
            let line4 = Array(pool[9 ..< 11])
            keyScheme = [line1, line2, line3, line4]
        }
    }
}

// MARK: - UI Layout

extension SRTKeyboardView {
    
    private func resetUIParameters() {
        let screenWidth = UIScreen.main.bounds.size.width
        if screenWidth < 370.0 { // iPhone SE 1st generation
            marginLeading = 3.0
        } else {
            buttonSize = CGSize(width: 35, height: 45)
        }
        let maxButtonCountPerRow = max(buttonCountLine1, buttonCountLine2, buttonCountLine3, buttonCountLine4)
        marginHorizontalBetweenButtons = Double(Int(screenWidth) - Int(buttonSize.width) * maxButtonCountPerRow - Int(marginLeading * 2)) / Double(maxButtonCountPerRow - 1)
        marginVerticalBetweenButtons = Double(Int(SRTKeyboardView.keyboardHeight - marginTop * 2) - Int(buttonSize.height) * buttonLines) / Double(buttonLines - 1)
        
        firstAlphaPosition.removeAll()
        switch keyboardType {
        case .numeric:
            firstAlphaPosition.append(CGPoint(x: marginLeading, y: marginTop))
            firstAlphaPosition.append(CGPoint(x: marginLeading, y: marginTop + Double(numericButtonSize.height) + marginVerticalBetweenButtons))
            let leadingOfSKey = (Double(screenWidth) - Double(numericButtonSize.width * CGFloat(numericButtonCount)) - marginHorizontalBetweenButtons * Double(numericButtonCount - 1)) / 2.0

            var line3x = marginLeading + marginHorizontalBetweenButtons + numericButtonSize.width
            var line4x = leadingOfSKey
            if keyboardType == .symbol {
                line3x = marginLeading
                line4x = marginLeading
            }

            firstAlphaPosition.append(CGPoint(x: line3x, y: marginTop + Double(numericButtonSize.height * 2.0) + marginVerticalBetweenButtons + marginVerticalBetweenButtons))
            firstAlphaPosition.append(CGPoint(x: line4x, y: marginTop + Double(numericButtonSize.height * 3.0) + marginVerticalBetweenButtons + marginVerticalBetweenButtons + marginVerticalBetweenButtons))
        default:
            firstAlphaPosition.append(CGPoint(x: marginLeading, y: marginTop))
            firstAlphaPosition.append(CGPoint(x: marginLeading, y: marginTop + Double(buttonSize.height) + marginVerticalBetweenButtons))
            let leadingOfSKey = (Double(screenWidth) - Double(buttonSize.width * CGFloat(buttonCountLine4)) - marginHorizontalBetweenButtons * Double(buttonCountLine4 - 1)) / 2.0

            var line3x = marginLeading + marginHorizontalBetweenButtons + buttonSize.width
            var line4x = leadingOfSKey
            if keyboardType == .symbol {
                line3x = marginLeading
                line4x = marginLeading
            }

            firstAlphaPosition.append(CGPoint(x: line3x, y: marginTop + Double(buttonSize.height * 2.0) + marginVerticalBetweenButtons + marginVerticalBetweenButtons))
            firstAlphaPosition.append(CGPoint(x: line4x, y: marginTop + Double(buttonSize.height * 3.0) + marginVerticalBetweenButtons + marginVerticalBetweenButtons + marginVerticalBetweenButtons))
        }
    }
    
    private func setUIParameters() {
        let screenWidth = UIScreen.main.bounds.size.width
        if screenWidth < 370.0 { // iPhone SE 1st generation
            marginLeading = 3.0
        } else {
            buttonSize = CGSize(width: 35, height: 45)
        }
        let maxButtonCountPerRow = max(buttonCountLine1, buttonCountLine2, buttonCountLine3, buttonCountLine4)
        marginHorizontalBetweenButtons = Double(Int(screenWidth) - Int(buttonSize.width) * maxButtonCountPerRow - Int(marginLeading * 2)) / Double(maxButtonCountPerRow - 1)
        marginVerticalBetweenButtons = Double(Int(SRTKeyboardView.keyboardHeight - marginTop * 2) - Int(buttonSize.height) * buttonLines) / Double(buttonLines - 1)
        firstAlphaPosition.append(CGPoint(x: marginLeading, y: marginTop))
        firstAlphaPosition.append(CGPoint(x: marginLeading, y: marginTop + Double(buttonSize.height) + marginVerticalBetweenButtons))
        let leadingOfSKey = (Double(screenWidth) - Double(buttonSize.width * CGFloat(buttonCountLine4)) - marginHorizontalBetweenButtons * Double(buttonCountLine4 - 1)) / 2.0
        firstAlphaPosition.append(CGPoint(x: marginLeading + marginHorizontalBetweenButtons + buttonSize.width, y: marginTop + Double(buttonSize.height * 2.0) + marginVerticalBetweenButtons + marginVerticalBetweenButtons))
        firstAlphaPosition.append(CGPoint(x: leadingOfSKey, y: marginTop + Double(buttonSize.height * 3.0) + marginVerticalBetweenButtons + marginVerticalBetweenButtons + marginVerticalBetweenButtons))
        let functionButtonWidth = leadingOfSKey - marginHorizontalBetweenButtons - marginLeading
        functionButtonSize = CGSize(width: CGFloat(functionButtonWidth), height: buttonSize.height - 1) // Leave one pixel for the shadow

        createCanvas()
    }

    private func createCanvas() {
        var view: UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(SRTKeyboardView.titleHeight)
            }
            $0.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8352941176, blue: 0.8588235294, alpha: 1)
            return $0
        }(UIView())
        accessoryView = view
        
        
        let label: UILabel = { [weak self] in
            self?.accessoryView.addSubview($0)
            $0.textColor = .black
            $0.backgroundColor = .clear
            $0.textAlignment = .center
            $0.font = UIFont(name: "PingFangSC-Regular", size: 16)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }
            return $0
        }(UILabel())
        accessoryTitleLabel = label
        
        
        view = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-SRTKeyboardView.bottomPadding)
                make.height.equalTo(SRTKeyboardView.keyboardHeight)
            }
            $0.backgroundColor = .darkGray
            return $0
        }(UIView())
        kyeboardContainer = view
        
        
        
        let button: UIButton = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.addSubview($0)
            $0.setTitle("完成", for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1), for: .normal)
            $0.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
            $0.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-9)
                make.centerY.equalToSuperview()
            }
            return $0
        }(UIButton())
        finishButton = button
        button.addTarget(self, action: #selector(tapFinishButton(_:)), for: .touchUpInside)
        
        let symbolAndAlphaBtn: UIButton = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.addSubview($0)
            $0.setTitle("符号", for: .normal)
            $0.setTitle("ABC", for: .selected)
            $0.setTitleColor(#colorLiteral(red: 0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1), for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1), for: .selected)
            $0.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
            $0.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(9)
                make.centerY.equalToSuperview()
            }
            return $0
        }(UIButton())
        changeKeyBoardTypeButton = symbolAndAlphaBtn
        symbolAndAlphaBtn.addTarget(self, action: #selector(tapChangeSymbolOrAlphaButton(_:)), for: .touchUpInside)

        let numericAndAlphaBtn: UIButton = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.addSubview($0)
            $0.setTitle("123", for: .normal)
            $0.setTitle("ABC", for: .selected)
            $0.setTitleColor(#colorLiteral(red: 0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1), for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1), for: .selected)
            $0.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
            $0.snp.makeConstraints { make in
                make.left.equalTo(symbolAndAlphaBtn.snp_right).offset(18)
                make.centerY.equalToSuperview()
            }
            return $0
        }(UIButton())
        changeKeyBoardTypeButton = numericAndAlphaBtn
        numericAndAlphaBtn.addTarget(self, action: #selector(tapChangeNumericOrAlphaButton(_:)), for: .touchUpInside)
    }

    private func createButton(for row: Int) {
        guard row < buttonLines else { return }

        switch keyboardType {
        case .numeric:
            let startPoint = CGPoint(x: 5.0, y: firstAlphaPosition[row].y)
            var leading = Double(startPoint.x)
            let keyItems = keys(for: row)
            for keyItem in keyItems {
                let button: SRTKeyboardButton = {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    kyeboardContainer.addSubview($0)
                    $0.snp.makeConstraints { make in
                        make.size.equalTo(numericButtonSize)
                        make.leading.equalToSuperview().offset(leading)
                        make.top.equalToSuperview().offset(startPoint.y)
                    }
                    buttons.append($0)
                    return $0
                }(SRTKeyboardButton())
                button.input = keyItem.rawValue
                button.securityType = .security(textBox: self)
                if let textInput = textInput {
                    button.textInput = textInput
                }

                leading += Double(numericButtonSize.width) + numericMarginHorizontalBetweenButtons
            }
        default:
            let startPoint = firstAlphaPosition[row]
            var leading = Double(startPoint.x)
            let keyItems = keys(for: row)
            for keyItem in keyItems {
                let button: SRTKeyboardButton = {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    kyeboardContainer.addSubview($0)
                    $0.snp.makeConstraints { make in
                        make.size.equalTo(buttonSize)
                        make.leading.equalToSuperview().offset(leading)
                        make.top.equalToSuperview().offset(startPoint.y)
                    }
                    buttons.append($0)
                    return $0
                }(SRTKeyboardButton())
                button.input = keyItem.rawValue
                button.securityType = .security(textBox: self)
                if let textInput = textInput {
                    button.textInput = textInput
                }

                leading += Double(buttonSize.width) + marginHorizontalBetweenButtons
            }
        }
    }

    private func createFunctionButtons() {
        // create capslock button
        guard let path = Bundle.main.path(forResource: "HCSecurityKeyboard", ofType: "framework", inDirectory: "Frameworks") else { return }
        let bundle = Bundle(path: path)
        guard let url = bundle?.url(forResource: "HCSecurityKeyboard", withExtension: "bundle") else { return }

        let leading = marginLeading
        let bottom = marginTop
        if keyboardType == .alphaAndNumeric {
            var image: UIImage = UIImage(named: "keyboard_space@3x", in: Bundle(url: url), compatibleWith: nil) ?? UIImage()
            var button: UIButton = {
                $0.translatesAutoresizingMaskIntoConstraints = false
                kyeboardContainer.addSubview($0)
                $0.setImage(image, for: .normal)
                $0.layer.cornerRadius = 5.0
                $0.layer.shadowColor = #colorLiteral(red: 0.5333333333, green: 0.5411764706, blue: 0.5568627451, alpha: 1).cgColor
                $0.layer.shadowOffset = CGSize(width: 0.1, height: 1.1)
                $0.layer.shadowRadius = 0
                $0.layer.shadowOpacity = 1.0
                $0.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                $0.snp.makeConstraints { make in
                    make.size.equalTo(functionButtonSize)
                    make.leading.equalToSuperview().offset(leading)
                    make.bottom.equalToSuperview().offset(-bottom - 1) // 留一个像素给阴影
                }
                $0.tag = SRTFunctionKeyType.space.rawValue
                functionButtons.append($0)
                return $0
            }(UIButton())
            button.addTarget(self, action: #selector(tapFunctionButton(_:)), for: .touchUpInside)
            
            image = UIImage(named: "keyboard_shift@3x", in: Bundle(url: url), compatibleWith: nil) ?? UIImage()
            button = {
                $0.translatesAutoresizingMaskIntoConstraints = false
                kyeboardContainer.addSubview($0)
                $0.setImage(image, for: .normal)
                $0.layer.cornerRadius = 5.0
                $0.layer.shadowColor = #colorLiteral(red: 0.5333333333, green: 0.5411764706, blue: 0.5568627451, alpha: 1).cgColor
                $0.layer.shadowOffset = CGSize(width: 0.1, height: 1.1)
                $0.layer.shadowRadius = 0
                $0.layer.shadowOpacity = 1.0
                $0.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                $0.snp.makeConstraints { make in
                    make.size.equalTo(buttonSize)
                    make.leading.equalToSuperview().offset(leading)
                    make.bottom.equalToSuperview().offset(-bottom - 1 - buttonSize.height - marginVerticalBetweenButtons) // 留一个像素给阴影
                }
                $0.tag = SRTFunctionKeyType.capsLock.rawValue
                functionButtons.append($0)
                return $0
            }(UIButton())
            button.addTarget(self, action: #selector(tapFunctionButton(_:)), for: .touchUpInside)
        }
        
        if keyboardType == .symbol {
            let image: UIImage = UIImage(named: "keyboard_space@3x", in: Bundle(url: url), compatibleWith: nil) ?? UIImage()
            let button: UIButton = {
                $0.translatesAutoresizingMaskIntoConstraints = false
                kyeboardContainer.addSubview($0)
                $0.setImage(image, for: .normal)
                $0.layer.cornerRadius = 5.0
                $0.layer.shadowColor = #colorLiteral(red: 0.5333333333, green: 0.5411764706, blue: 0.5568627451, alpha: 1).cgColor
                $0.layer.shadowOffset = CGSize(width: 0.1, height: 1.1)
                $0.layer.shadowRadius = 0
                $0.layer.shadowOpacity = 1.0
                $0.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                $0.snp.makeConstraints { make in
                    make.height.equalTo(functionButtonSize.height)
                    make.leading.equalToSuperview().offset(leading + buttonSize.width * 2 + marginHorizontalBetweenButtons * 2)
                    make.trailing.equalToSuperview().offset(-bottom - 1 - functionButtonSize.width - marginHorizontalBetweenButtons)
                    make.bottom.equalToSuperview().offset(-bottom - 1) // 留一个像素给阴影
                }
                $0.tag = SRTFunctionKeyType.space.rawValue
                functionButtons.append($0)
                return $0
            }(UIButton())
            button.addTarget(self, action: #selector(tapFunctionButton(_:)), for: .touchUpInside)
        }
        
        // create backspace button
        let image = UIImage(named: "keyboard_delete@3x", in: Bundle(url: url), compatibleWith: nil) ?? UIImage()
        let button: UIButton = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            kyeboardContainer.addSubview($0)
            $0.setImage(image, for: .normal)
            $0.layer.cornerRadius = 5.0
            $0.layer.shadowOffset = CGSize(width: 0.1, height: 1.1)
            $0.layer.shadowColor = #colorLiteral(red: 0.5333333333, green: 0.5411764706, blue: 0.5568627451, alpha: 1).cgColor
            $0.layer.shadowRadius = 0
            $0.layer.shadowOpacity = 1.0
            $0.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            $0.snp.makeConstraints { make in
                switch keyboardType {
                case .numeric:
                    make.size.equalTo(CGSize(width: numericButtonSize.width, height: numericButtonSize.height - 1))
                default:
                    make.size.equalTo(functionButtonSize)
                }
                make.bottom.equalToSuperview().offset(-bottom - 1) // Leave one pixel for the shadow
                make.trailing.equalToSuperview().offset(-leading)
            }
            $0.tag = SRTFunctionKeyType.backspace.rawValue
            functionButtons.append($0)
            return $0
        }(UIButton())
        button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(deleteLongPressFunction(_:))))
        button.addTarget(self, action: #selector(tapFunctionButton(_:)), for: .touchUpInside)
    }
}

// MARK: - SRTSecurityTextBox

extension SRTKeyboardView: SRTSecurityTextBox {
    func append(_ text: String) {
        let newString = plainText + text
        textStore = encodeText(newString)
        observeTextChanged?()
    }

    var plainText: String {
        return decodeText(textStore)
    }

    private func removeLast() {
        let current = plainText
        let newString = String(current[..<current.index(before: current.endIndex)])
        textStore = encodeText(newString)
        observeTextChanged?()
    }

    private func encodeText(_ source: String) -> [UInt8] {
        return Array(source).map { ($0.asciiValue ?? 0) + encodeOffet }
    }

    private func decodeText(_ source: [UInt8]) -> String {
        let chars = source.map { Character(UnicodeScalar($0 - encodeOffet)) }
        return String(chars)
    }
}

extension UITextField {
    var nsRangeValue: NSRange {
        let location = text?.count ?? 0
        return NSRange(location: location, length: 0)
    }
}
