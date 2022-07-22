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

public class SRTAppendTextField: UITextField {
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Disable select and paste operations
        return false
    }

    override public func closestPosition(to point: CGPoint) -> UITextPosition? {
        // It is forbidden to change the cursor position, because the security keyboard does not support insert and replace operations. only allow append
        let beginning = beginningOfDocument
        let end = position(from: beginning, offset: text?.count ?? 0)
        return end
    }
}
