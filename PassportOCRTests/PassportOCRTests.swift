//
//  PassportOCRTests.swift
//  PassportOCRTests
//
//  Created by Михаил on 06.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import XCTest
@testable import PassportOCR

class PassportOCRTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleCase() {
        let mrCode = "P<AFGERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<\nL898902C<3AFG6908061F9406236ZE184226B<<<<<14"
        let info = PassportInfo(machineReadableCode: mrCode)
        XCTAssert(info != nil)
        print(info!)
    }
    
    func testPerformanceExample() {
        self.measureBlock {
            self.testSimpleCase()
        }
    }
    
}
