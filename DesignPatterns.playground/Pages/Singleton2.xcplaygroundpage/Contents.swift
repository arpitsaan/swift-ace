/*
Question:
Implement the Singleton pattern in Swift to ensure a class has only one instance and provide a global point of access to it. Create a class called `Logger` that logs messages. Ensure that there is only one instance of the `Logger` class.

Optional Challenge:
Extend your `Logger` class to keep a log history and implement a method to search for a specific log message within the log history.

Requirements:
1. Implement the Singleton pattern.
2. Create a `Logger` class with a method to log messages.
3. Ensure only one instance of the `Logger` class is used.
4. Extend the `Logger` class to keep a log history.
5. Implement a method to search for a specific log message within the log history.

Example Test Case:
1. Verify Singleton:
   - Create two references to `Logger` and ensure both refer to the same instance.
   ```swift
   let logger1 = Logger.shared
   let logger2 = Logger.shared
   assert(logger1 === logger2, "Both references should point to the same instance")
 
2. Log Messages:

   Log a few messages.
  
   logger1.log("First log message")
   logger1.log("Second log message")
   logger2.log("Third log message")
 
3. Search Log History:
  
   Search for a specific message in the log history.
  
   let searchResult1 = logger1.search("First log message")
   assert(searchResult1 == true, "The message should be found in the log history")
  
   let searchResult2 = logger2.search("Nonexistent message")
   assert(searchResult2 == false, "The message should not be found in the log history")

*/

import Foundation

protocol Logging {
    func log(_ message: String)
}

protocol Searching {
    func search(_ message: String) -> Bool
}

class Logger: Logging {
    
    static let shared = Logger()
    
    private var searchHistory: Set<String> = []

    private init() { }
    
    func log(_ message: String) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestampString = formatter.string(from: timestamp)
        print("[\(timestampString)] \(message)")
    }
    
}
        
extension Logger: Searching {
    
    func logWithHistory(_ message: String) {
        self.log(message)
        self.searchHistory.insert(message)
    }
    
    func search(_ message: String) -> Bool {
        return searchHistory.contains(message)
    }
}


//verify singleton
let logger1 = Logger.shared
let logger2 = Logger.shared
assert(logger1 === logger2, "Both references should point to the same instance")

//verify logs
logger1.log("First log message")
logger1.log("Second log message")
logger2.log("Third log message")

//verify history
logger2.logWithHistory("First log message")
logger1.logWithHistory("Second log message")
logger2.logWithHistory("Third log message")

let searchResult1 = logger1.search("First log message")
assert(searchResult1 == true, "The message should be found in the log history")

let searchResult2 = logger2.search("Nonexistent message")
assert(searchResult2 == false, "The message should not be found in the log history")
