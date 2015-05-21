# DGTAsync
DGTAsync was inspired by duemunk/Async. But it was written from the ground up to be able to handle an async tasks such as Alamofire download/upload tasks. It also can handle errors.

## CocoaPods Installation
    pod 'DGTAsync'

## Usage

    import DGTAsync

### Basic

Every DGTAsync tasks (blocks) have to accept one `cb` parameter which is a `async_done_callback` type.
And then, when the tasks finished you have to call `cb(nil)` to let DGTAsync know that your tasks have done.

```
DGTAsync.background { cb in
  self.syncTask()
  cb(nil)
}
```
### Doing asynchronous tasks in DGTAsync

Just call the `cb(nil)` when the tasks done.

```
DGTAsync.background { cb in
  self.asyncTask(cb)
}

func asyncTask(cb: async_done_callback) {
  self.doSomethingWithCompletionHandler {
    cb(nil)
  }
}
```

### Chaining (Synchronously)

You can do chaining asynchronous tasks synchronously.

```
DGTAsync.background { cb in
  self.asyncTask(cb)
}.background { cb in
  // Enter here only after asyncTask done
  self.syncTask() 
  cb(nil)
}.main { cb in
  // Enter here only after syncTask done (because we put cb(nil) after it, make sense?)
  self.doSomethingInMainQueue()
  cb(nil)
}
```

### Handling Errors (NSError)

You can use `.err` to register an error handler. And you can pass a NSError object to the `cb` like `cb(error)`.
When the NSError object is passed to the `cb` DGTAsync will skip all the chains and go right straight to the `.err` handler.

```
DGTAsync.background { cb in
  Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
         .response { (request, response, data, error) in
                     cb(error)
                   }
}.background { cb in
  // This block will be skipped if the request has error
  self.doSomethingAfterGetResponse()
  cb(nil)
}.main { cb in
  // This block also will be skipped if the request has error
  self.updateUI()
  cb(nil)
}.err { error in
  println("Request Error: \(error.localizedDescription)")
}
```

### Parallel Tasks

DGTAsync can also handle parallel tasks (but BEWARE about race condition and deadlock. YOU HAVE BEEN WARNED!)

When working with parallel tasks you have to work with another set of DGTAsync API that every methods have been prefixed with `p`. There are `pbackground`, `pmain` and `pdone` that will let you know when your tasks done.

All task will begin execute just right after you call `pbackground` and/or `pmain` they don't wait anything.

The example below demonstrate how to parallel upload multiple files and know when it's done.

```
DGTAsync.pbackground { cb in
  Alamofire.upload(.POST, "http://server.com/upload", file: fileURL1)
         .responseJSON { (request, response, data, error) in
                     cb(error)
                   }
}.pbackground { cb in
  Alamofire.upload(.POST, "http://server.com/upload", file: fileURL2)
         .responseJSON { (request, response, data, error) in
                     cb(error)
                   }
}.pbackground { cb in
  Alamofire.upload(.POST, "http://server.com/upload", file: fileURL3)
         .responseJSON { (request, response, data, error) in
                     cb(error)
                   }
}.pdone { 
  println("All files have been uploaded.")
}
```

## License

DGTAsync is released under the MIT license. See LICENSE for details.
