//
//  DGTAsync.swift
//
//  Created by 0angelic0 on 4/20/15.
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

import Foundation

public typealias async_done_callback = (NSError?) -> Void
public typealias async_err_callback = (NSError) -> Void
public typealias async_dispatch_block_t = ( async_done_callback ) -> Void

public class DGTAsync {
    
    private var block: dispatch_block_t?
    private var queue: dispatch_queue_t?
    private var next: DGTAsync?
    private var err_callback: async_err_callback?
    
    public static func background(async_block: async_dispatch_block_t) -> DGTAsync {
        let anAsync = DGTAsync(async_block: async_block)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), anAsync.block!)
        return anAsync
    }
    
    public static func main(async_block: async_dispatch_block_t) -> DGTAsync {
        let anAsync = DGTAsync(async_block: async_block)
        dispatch_async(dispatch_get_main_queue(), anAsync.block!)
        return anAsync
    }
    
    public func background(async_block: async_dispatch_block_t) -> DGTAsync {
        next = DGTAsync(async_block: async_block)
        next?.queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        return next!
    }
    
    public func main(async_block: async_dispatch_block_t) -> DGTAsync {
        next = DGTAsync(async_block: async_block)
        next?.queue = dispatch_get_main_queue()
        return next!
    }
    
    public func err(err_callback: async_err_callback) -> Void {
        self.err_callback = err_callback
    }
    
    private func callback(error: NSError?) -> Void {
        if error == nil {
            self.async_block_done()
        }
        else {
            if let err_cb = self.err_callback {
                err_cb(error!)
            }
            else {
                if let nextDGTAsync = self.next {
                    nextDGTAsync.callback(error!)
                }
            }
        }
    }
    
    private init(async_block: async_dispatch_block_t) {
        let b = { () -> Void in
            async_block(self.callback)
        }
        
        let _block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, b)
        self.block = _block
    }
    
    private func async_block_done() {
        if next != nil {
            dispatch_async(next!.queue!, next!.block!)
        }
    }
}