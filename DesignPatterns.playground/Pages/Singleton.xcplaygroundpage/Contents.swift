/***
    Problem 1: Singleton Pattern

    Description:
    Implement a Logger class using the Singleton pattern. The Logger should have a method to log messages, and it should ensure that only one instance of the Logger exists throughout the application.
 
    Requirements:
    Create a Logger class with a private initializer.
    Implement a static property to hold the single instance of the Logger.
    Implement a log(message: String) method that prints the message with a timestamp.
    Ensure that multiple calls to get the Logger instance return the same object.

    Example:
    swift
    let logger1 = Logger.shared
    logger1.log(message: "This is a log message")

    let logger2 = Logger.shared
    logger2.log(message: "Another log message")

    print(logger1 === logger2) // Should print: true
 */



import Foundation

class Logger {
    
    public static let shared = Logger()
    
    private init() {}
    
    public func log(message: String) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestampString = formatter.string(from: timestamp)
        print("[\(timestampString)] \(message)")
    }
}

let logger1 = Logger.shared
logger1.log(message: "This is a log message")

let logger2 = Logger.shared
logger2.log(message: "Another log message")

print(logger1 === logger2) // Should print: true

//Logger()
