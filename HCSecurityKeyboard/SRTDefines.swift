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

import Foundation

enum SRTKeyItemType {
    case numeric
    case alpha
    case function
    case symbol
}

enum SRTKeyBoardType {
    case alphaAndNumeric // 字母 + 数字 键盘
    case symbol          // 符号键盘
    case numeric         // 数字键盘
}

enum SRTKeyItem: String {
    case alpha1 = "1"
    case alpha2 = "2"
    case alpha3 = "3"
    case alpha4 = "4"
    case alpha5 = "5"
    case alpha6 = "6"
    case alpha7 = "7"
    case alpha8 = "8"
    case alpha9 = "9"
    case alpha0 = "0"
    case alphaQ = "q"
    case alphaW = "w"
    case alphaE = "e"
    case alphaR = "r"
    case alphaT = "t"
    case alphaY = "y"
    case alphaU = "u"
    case alphaI = "i"
    case alphaO = "o"
    case alphaP = "p"
    case alphaA = "a"
    case alphaS = "s"
    case alphaD = "d"
    case alphaF = "f"
    case alphaG = "g"
    case alphaH = "h"
    case alphaJ = "j"
    case alphaK = "k"
    case alphaL = "l"
    case alphaZ = "z"
    case alphaX = "x"
    case alphaC = "c"
    case alphaV = "v"
    case alphaB = "b"
    case alphaN = "n"
    case alphaM = "m"
    case funcShift = "shift"
    case funcSpace = "space"
    case funcBackspace = "backspace"
    
    case symbol1 = "&"
    case symbol2 = "\""
    case symbol3 = ";"
    case symbol4 = "^"
    case symbol5 = ","
    case symbol6 = "|"
    case symbol7 = "$"
    case symbol8 = "*"
    case symbol9 = ":"
    case symbol10 = "'"
    case symbol11 = "?"
    case symbol12 = "{"
    case symbol13 = "["
    case symbol14 = "~"
    case symbol15 = "#"
    case symbol16 = "}"
    case symbol17 = "."
    case symbol18 = "]"
    case symbol19 = "\\"
    case symbol20 = "!"
    case symbol21 = "("
    case symbol22 = "%"
    case symbol23 = "-"
    case symbol24 = "_"
    case symbol25 = "+"
    case symbol26 = "/"
    case symbol27 = ")"
    case symbol28 = "="
    case symbol29 = "<"
    case symbol30 = "`"
    case symbol31 = ">"
    case symbol32 = "@"
    
    var itemType: SRTKeyItemType {
        switch self {
        case .alpha1,
             .alpha2,
             .alpha3,
             .alpha4,
             .alpha5,
             .alpha6,
             .alpha7,
             .alpha8,
             .alpha9,
             .alpha0:
            return .numeric
        case .alphaQ,
             .alphaW,
             .alphaE,
             .alphaR,
             .alphaT,
             .alphaY,
             .alphaU,
             .alphaI,
             .alphaO,
             .alphaP,
             .alphaA,
             .alphaS,
             .alphaD,
             .alphaF,
             .alphaG,
             .alphaH,
             .alphaJ,
             .alphaK,
             .alphaL,
             .alphaZ,
             .alphaX,
             .alphaC,
             .alphaV,
             .alphaB,
             .alphaN,
             .alphaM:
            return .alpha
        case .funcShift,
             .funcSpace,
             .funcBackspace:
            return .function
        default:
            return .symbol
        }
    }

    var isFunctionItem: Bool {
        return itemType == .function
    }
}

enum SRTFunctionKeyType: Int {
    case capsLock = 500
    case space = 501
    case backspace = 502
}

protocol SRTSecurityTextBox {
    func append(_ text: String)
    var plainText: String { get }
    var textLimited: Int { get }
}

enum SRTButtonType {
    case normal
    case security(textBox: SRTSecurityTextBox)
}
