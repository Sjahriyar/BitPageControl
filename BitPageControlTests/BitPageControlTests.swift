//
//  BitPageControlTests.swift
//  BitPageControlTests
//
//  Created by Wise Sapien on 24/08/2020.
//  Copyright © 2020 Shahriar. All rights reserved.
//

import XCTest
@testable import BitPageControl

class BitPageControlTests: XCTestCase {

    var bitPageControl: BitPageControlWithTiming!
    
    override func setUpWithError() throws {
        self.bitPageControl = BitPageControlWithTiming()
    }

    override func tearDownWithError() throws {
        self.bitPageControl = nil
    }

    func testNumberOfPages() {
        self.bitPageControl.numberOfPages = 10
        
        XCTAssertEqual(self.bitPageControl.indicators.count, self.bitPageControl.numberOfPages, "Not equal")
    }

}
