//
//  PassportInfo.swift
//  PassportOCR
//
//  Created by Михаил on 05.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation
import Boilerplate
import Regex
import Result.Swift
import TesseractOCR

enum Sex {
    case Male, Female, Unknown
}

struct PassportInfo {
    private static let filePath = NSBundle.mainBundle().pathForResource("passportPattern", ofType: "txt")
    private static let contentData = NSFileManager.defaultManager().contentsAtPath(filePath!)
    private static let passportPattern = NSString(data: contentData!, encoding: NSUTF8StringEncoding) as! String
    
    let countryCode: String
    let surname: String
    let names: [String]
    let passportNumber: String
    
    let nationalityCode: String
    let dayOfBirth: NSDate?
    let sex: Sex
    let expiralDate: NSDate?
    let personalNumber: String
    
//    let checkDigit1: Int
//    let checkDigit2: Int
//    let checkDigit3: Int
//    let checkDigit4: Int
    
    init?(machineReadableCode code: String) {
        var regex: NSRegularExpression!
        
        do {
            regex = try NSRegularExpression(pattern: PassportInfo.passportPattern, options: [])
        }
        catch {
            print("error pattern")
            return nil
        }
        
        let range = NSRange(location: 0, length: code.characters.count)
        if let result = regex.firstMatchInString(code, options: [], range: range) {
            countryCode = result.group(atIndex: 4, fromSource: code)
            surname = result.group(atIndex: 6, fromSource: code)
            names = result.group(atIndex: 7, fromSource: code).componentsSeparatedByString("<")
            passportNumber = result.group(atIndex: 9, fromSource: code)
            nationalityCode = result.group(atIndex: 11, fromSource: code)
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: code)
            dayOfBirth = NSDate.dateFromPassportDateCode(dayOfBirthCode)
            
            let sexLetter = result.group(atIndex: 17, fromSource: code)
            switch sexLetter {
            case "F":
                sex = .Female
            case "M":
                sex = .Male
            default:
                NSLog("Error: unknown sex in \(code)")
                sex = .Unknown
            }
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: code)
            expiralDate = NSDate.dateFromPassportDateCode(expiralDateCode)
            
            personalNumber = result.group(atIndex: 23, fromSource: code)
        }
        else {
            print("no match result")
            return nil
        }
    }
    
    init?(image: UIImage) {
        let tesseract = G8Tesseract(language: "eng")
        
        tesseract.image = image
        tesseract.charWhitelist = Constants.alphabet.uppercaseString
        tesseract.charWhitelist.append("<>1234567890")
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            print("RECOGNIZED: \(recognizedText)")
            
            let mrCode = tesseract.recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
            print(mrCode)
            self.init(machineReadableCode: mrCode)
        }
        else {
            self.init(machineReadableCode: "")
        }
    }
}











