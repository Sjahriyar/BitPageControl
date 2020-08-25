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
    var kvoToken: NSKeyValueObservation?
    var isAnimating: Bool?
    
    override func setUpWithError() throws {
        self.bitPageControl = BitPageControlWithTiming()
        
        self.kvoToken = self.bitPageControl.observe(\.currentPage, options: .new) { (bitPageControl, change) in
            
            guard change.newValue != nil else { return }
            
            self.isAnimating = true
        }
    }

    override func tearDownWithError() throws {
        self.bitPageControl = nil
        self.kvoToken?.invalidate()
    }

    func testNumberOfPages() {
        self.bitPageControl.numberOfPages = 10
        
        XCTAssertEqual(self.bitPageControl.indicators.count, self.bitPageControl.numberOfPages, "Not equal")
    }
    
    func testNumberOfPagesInvalidValue() {
        self.bitPageControl.numberOfPages = 0
        
        XCTAssertEqual(self.bitPageControl.indicators.count, 0)
    }
    
    func testCurrentPageInvalidRange() {
        self.bitPageControl.numberOfPages = 4
        self.bitPageControl.currentPage = -1
        
        XCTAssertNotEqual(self.bitPageControl.currentPage, 100)
        
        self.bitPageControl.currentPage = 1000
        
        XCTAssertNotEqual(self.bitPageControl.currentPage, 1000)
    }
    
    func testDurationOutOfRange() {
        self.bitPageControl.numberOfPages = 10
        self.bitPageControl.setFillingDurationForIndicators([])
        
        XCTAssertEqual(self.bitPageControl.fillAnimationDuration.count, 1)
        
        self.bitPageControl.setFillingDurationForIndicators([1.2, 1.0])
        
        XCTAssertEqual(self.bitPageControl.fillAnimationDuration.count, 2)
    }
    
    func testIndicatorAnimationStartsOnCurrentPageSet() {
        self.bitPageControl.numberOfPages = 10
        self.bitPageControl.currentPage = 3
        
        XCTAssertNotNil(self.isAnimating)
    }

}
