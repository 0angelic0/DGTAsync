//
//  DGTAsyncTests.swift
//  DGTAsyncTests
//
//  Created by 0angelic0 on 5/13/15.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Digitopolis Co., Ltd.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import XCTest

class Output {
    var array: [String] = []
    func add(value: String) {
        array.append(value)
    }
}

class DGTAsyncTests: XCTestCase {
    
    func asyncTask(cb: async_done_callback, _ output: Output) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            output.add("asyncTask")
            cb(nil)
        }
    }
    
    func asyncTaskError(cb: async_done_callback, _ output: Output) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            output.add("asyncTaskError")
            let error = NSError(domain: "DGTAsyncErrorDomain", code: 1, userInfo: nil)
            cb(error)
        }
    }
    
    func testChaining() {
        let expectation: XCTestExpectation = self.expectationWithDescription("DGTAsync Chaining")
        
        var output = Output()
        DGTAsync.background { cb in
            output.add("1")
            cb(nil)
        }.background { cb in
            output.add("2")
            cb(nil)
        }.background { cb in
            output.add("3")
            cb(nil)
        }.main { cb in
            XCTAssertEqual(output.array, ["1", "2", "3"], "Chaining")
            expectation.fulfill()
            cb(nil)
        }
        
        self.waitForExpectationsWithTimeout(3, handler: { (error: NSError?) -> Void in
            if let desc = error?.localizedDescription {
                println("done with error = \(desc)")
            }
            else {
                println("done with no error")
            }
        })
    }
    
    func testAsync() {
        let expectation: XCTestExpectation = self.expectationWithDescription("DGTAsync can handle async tasks")
        
        var output = Output()
        DGTAsync.background { cb in
            output.add("1")
            cb(nil)
        }.background { cb in
            output.add("2")
            self.asyncTask(cb, output)
        }.background { cb in
            output.add("3")
            cb(nil)
        }.background { cb in
            output.add("4")
            self.asyncTask(cb, output)
        }.main { cb in
            XCTAssertEqual(output.array, ["1", "2", "asyncTask", "3", "4", "asyncTask"], "Async Tasks")
            expectation.fulfill()
            cb(nil)
        }
        
        self.waitForExpectationsWithTimeout(3, handler: { (error: NSError?) -> Void in
            if let desc = error?.localizedDescription {
                println("done with error = \(desc)")
            }
            else {
                println("done with no error")
            }
        })
    }
    
    func testError() {
        let expectation: XCTestExpectation = self.expectationWithDescription("DGTAsync can handle error")
        
        var output = Output()
        DGTAsync.background { cb in
            output.add("1")
            cb(nil)
        }.background { cb in
            output.add("2")
            self.asyncTaskError(cb, output)
        }.background { cb in
            output.add("3")
            cb(nil)
        }.background { cb in
            output.add("4")
            self.asyncTask(cb, output)
        }.main { cb in
            cb(nil)
        }.err { error in
            XCTAssertEqual(output.array, ["1", "2", "asyncTaskError"], "Async Tasks Error")
            XCTAssertEqual(error.domain, "DGTAsyncErrorDomain", "Async Tasks Error")
            XCTAssertEqual(error.code, 1, "Async Tasks Error")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3, handler: { (error: NSError?) -> Void in
            if let desc = error?.localizedDescription {
                println("done with error = \(desc)")
            }
            else {
                println("done with no error")
            }
        })
    }
    
}
