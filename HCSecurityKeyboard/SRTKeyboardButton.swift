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

import UIKit

class SRTKeyboardButton: UIControl {
    // MARK: - Properties

    var input = "" {
        didSet {
            inputLabel?.text = input
        }
    }

    var font = UIFont.systemFont(ofSize: 22.0) {
        didSet {
            inputLabel?.font = font
        }
    }

    var keyColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    var keyTextColor: UIColor = .white {
        didSet {
            inputLabel?.textColor = keyTextColor
        }
    }

    var keyShadowColor: UIColor = #colorLiteral(red: 0.5333333333, green: 0.5411764706, blue: 0.5568627451, alpha: 1)
    var keyHighlightedColor: UIColor = #colorLiteral(red: 0.8352941176, green: 0.8392156863, blue: 0.8470588235, alpha: 1)
    weak var textInput: UITextInput?
    var securityType: SRTButtonType = .normal

    // MARK: - UI elements

    private weak var inputLabel: UILabel?
    private var keyCornerRadius: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateButtonPosition()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setNeedsDisplay()
        updateButtonPosition()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let color = state == .highlighted ? keyHighlightedColor : keyColor
        let shadowColor = keyShadowColor
        let shadowOffset = CGSize(width: 0.1, height: 1.1)
        let shadowBlurRadius: CGFloat = 0

        let roundedRectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - 1), cornerRadius: keyCornerRadius)
        context?.saveGState()
        context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadowColor.cgColor)
        color.setFill()
        roundedRectanglePath.fill()
        context?.restoreGState()
    }

    // MARK: - Touch actions

    @objc
    private func handleTouchDown() {
        UIDevice.current.playInputClick()
        setNeedsDisplay()
    }

    @objc
    private func handleTouchUpInside() {
        insertText(input)
        setNeedsDisplay()
    }

    @objc
    private func handleTouchDragOutside() {
        setNeedsDisplay()
    }

    @objc
    private func handleTouchDragInside() {
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

    // MARK: - Private methods

    private func commonInit() {
        backgroundColor = .clear
        clipsToBounds = false
        layer.masksToBounds = false
        contentHorizontalAlignment = .center

        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(handleTouchDragOutside), for: .touchDragOutside)
        addTarget(self, action: #selector(handleTouchDragInside), for: .touchDragInside)

        let inputLabel = UILabel(frame: frame)
        inputLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        inputLabel.textAlignment = .center
        inputLabel.backgroundColor = .clear
        inputLabel.isUserInteractionEnabled = false
        inputLabel.textColor = keyTextColor
        inputLabel.font = font

        addSubview(inputLabel)
        self.inputLabel = inputLabel

        setNeedsDisplay()
    }

    private func updateDisplayStyle() {
        setNeedsDisplay()
    }

    private func updateButtonPosition() {}

    private func showInputView() {
        setNeedsDisplay()
    }

    private func insertText(_ text: String) {
        guard let textInput = textInput else { return }
        var shouldInsertText = true

        switch securityType {
        case .normal:
            if let textView = textInput as? UITextView {
                // Call UITextViewDelegate methods if necessary
                let selectedRange = textView.selectedRange

                shouldInsertText = textView.delegate?.textView?(textView, shouldChangeTextIn: selectedRange, replacementText: text) ?? true
            } else if let textField = textInput as? UITextField {
                // Call UITextFieldDelgate methods if necessary
                let selectedRange = textInputSelectedRange

                shouldInsertText = textField.delegate?.textField?(textField, shouldChangeCharactersIn: selectedRange, replacementString: text) ?? true
            }
        case let .security(textBox):
            var currentText = ""

            if let textView = textInput as? UITextView {
                currentText = textView.text
            } else if let textField = textInput as? UITextField {
                currentText = textField.text ?? ""
            }
            shouldInsertText = currentText.count < textBox.textLimited
        }

        if shouldInsertText {
            switch securityType {
            case .normal:
                textInput.insertText(text)
            case let .security(textBox):
                // in security mode, only support append, insert and replace is denied
                if let textField = textInput as? UITextField {
                    textField.text = "\(textField.text ?? "")\(text)"
                } else if let textView = textInput as? UITextView {
                    textView.text += text
                }
                textBox.append(text)
            }
        }
    }

    private var textInputSelectedRange: NSRange {
        guard let textInput = textInput, let selectedRange = textInput.selectedTextRange else { return NSRange(location: 0, length: 0) }

        let beginning = textInput.beginningOfDocument

        let selectionStart = selectedRange.start
        let selectionEnd = selectedRange.end

        let location = textInput.offset(from: beginning, to: selectionStart)
        let length = textInput.offset(from: selectionStart, to: selectionEnd)

        return NSRange(location: location, length: length)
    }
}
