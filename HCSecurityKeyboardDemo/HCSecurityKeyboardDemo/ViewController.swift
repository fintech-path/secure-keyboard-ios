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
import HCSecurityKeyboard

class ViewController: UIViewController {
    @IBOutlet weak var textInput: SRTAppendTextField!
    @IBOutlet weak var inputOrginText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNonShuffleKeyBoardField()
    }
    
    private func setupNonShuffleKeyBoardField() {
        let keyboardView = SRTKeyboardView()
        keyboardView.title = "安全键盘"
        keyboardView.titleBackgroundColor = .darkGray
        keyboardView.titleColor = .white

        keyboardView.observeTextChanged = { [weak self] in
            self?.inputOrginText.text = "The input is： \(keyboardView.decryptedText)"
        }
        /*
        randomKeys
        false: Use the default keyboard format
        true: random keyboard is used for each initialization
        */
        keyboardView.randomKeys = false
        // Limit the number of inputs
        keyboardView.textLimited = 50
        textInput.delegate = self
        // Try to leave this sentence to the end, because this is when the component is initialized
        keyboardView.textInput = textInput
    }
}

extension ViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Disables input from external keyboards
        return false
    }
}