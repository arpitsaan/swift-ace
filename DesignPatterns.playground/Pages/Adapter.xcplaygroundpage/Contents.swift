/*
 What is the Adapter design pattern?
 The Adapter pattern is a structural design pattern that allows objects with incompatible interfaces to collaborate. It acts as a wrapper between two objects, catching calls for one object and transforming them to format and interface recognizable by the second object.
 Real-world applications:

 Legacy system integration in software modernization projects
 Third-party library integration in existing codebases
 Multi-platform development where different platforms have different APIs
 Database migration where old and new database systems have different query interfaces

 Advantages in this scenario:

 Allows integration of the third-party weather service without modifying existing code
 Maintains single responsibility principle by separating interface adaptation from core logic
 Enhances code reusability and flexibility

 Potential drawbacks:

 Increases overall code complexity by adding new classes
 May impact performance due to the additional layer of abstraction
 Can lead to overuse, resulting in an overly complicated design

 The Adapter pattern is particularly applicable to the current scenario because:

 We have an existing interface (WeatherData) that our application expects
 We need to integrate a new service (ThirdPartyWeatherService) with an incompatible interface
 We want to avoid modifying either the existing code or the third-party service

 Compared to other solutions, the Adapter pattern:

 Is more flexible than directly modifying the ThirdPartyWeatherService or our application code
 Provides better separation of concerns than trying to make the ThirdPartyWeatherService implement WeatherData directly
 Is simpler to implement and maintain than a complete redesign of the system

 Overall, your implementation demonstrates a good understanding of the Adapter pattern and its application in solving interface incompatibility issues.
 */

/*
Problem 6: Weather Data Integration using Adapter Pattern

Description:
You're developing a weather monitoring application that aggregates data from various sources. You need to integrate a third-party weather service that provides data in a format incompatible with your system. Additionally, you need to implement a moving average calculation for temperature data.

Why Adapter Pattern?
The Adapter pattern is ideal for this scenario because:
1. We have an existing system (your weather app) with a defined interface (WeatherData protocol).
2. We want to use a new, incompatible service (ThirdPartyWeatherService) without modifying our existing code.
3. We need to transform the data from one format to another without affecting either the source or the client code.
The Adapter acts as a bridge between these two incompatible interfaces, allowing them to work together seamlessly.

 Requirements:
 1. Create a WeatherData protocol that your application uses, with methods:
    - getTemperature() -> Double
    - getHumidity() -> Double
    - getPressure() -> Double
    Why: This represents the standardized interface your application expects for weather data.

 2. Create a ThirdPartyWeatherService class with a method getData() that returns a Dictionary with keys "temp", "hum", "pres" and their corresponding values.
    Why: This represents the external service with an incompatible interface.

 3. Implement a WeatherServiceAdapter class that adapts the ThirdPartyWeatherService to the WeatherData protocol.
    Why: This adapter will allow the third-party service to be used wherever WeatherData is expected.

 4. Implement a MovingAverageCalculator class with a method addTemperature(temp: Double) -> Double that adds a new temperature reading and returns the moving average of the last 5 readings.
    Why: This adds a data processing component to demonstrate integration of the adapter with other parts of your system.

 5. Demonstrate the use of the adapter and moving average calculator in a client code that expects WeatherData.
    Why: This shows how the adapter allows seamless integration of the third-party service and additional processing.

 Example usage:
 let thirdPartyService = ThirdPartyWeatherService()
 let adapter = WeatherServiceAdapter(service: thirdPartyService)
 let movingAverage = MovingAverageCalculator()

 // Client code
 func processWeatherData(weatherData: WeatherData) {
     let temp = weatherData.getTemperature()
     let avgTemp = movingAverage.addTemperature(temp: temp)
     print("Current Temperature: \(temp)")
     print("Moving Average Temperature: \(avgTemp)")
 }

 processWeatherData(weatherData: adapter)
 // Should print current temperature and its moving average

 Implement the Adapter pattern, MovingAverageCalculator, and related classes that satisfy these requirements.

 After implementing the solution, be prepared to discuss:
 1. Real-world applications of the Adapter pattern
 2. Advantages of using the Adapter pattern in this scenario
 3. Potential drawbacks or limitations of the Adapter pattern

 What is the Adapter design pattern?
 [You'll answer this after implementing the solution]
 */

protocol WeatherData {
    func getTemperature() -> Double
    func getHumidity() -> Double
    func getPressure() -> Double
}

class ThirdPartyWeatherService {
    private var temp: Double
    private var hum: Double
    private var pres: Double
    
    init() {
        self.temp = 0
        self.hum = 0
        self.pres = 0
    }
    
    init(temp: Double, hum: Double, pres: Double) {
        self.temp = temp
        self.hum = hum
        self.pres = pres
    }
    
    func getData() -> [String: Double] {
        return ["temp": temp, "hum": hum, "pres": pres]
    }
}

class WeatherServiceAdapter: WeatherData {
    
    private var service: ThirdPartyWeatherService
    
    init(service: ThirdPartyWeatherService) {
        self.service = service
    }
    
    func getTemperature() -> Double {
        return service.getData()["temp"] ?? 0
    }
    
    func getHumidity() -> Double {
        return service.getData()["hum"] ?? 0
    }
    
    func getPressure() -> Double {
        return service.getData()["pres"] ?? 0
    }
}

class MovingAverageCalculator {
    private var temperatures: [Double] = []
    private let windowSize = 5

    func addTemperature(temp: Double) -> Double {
        temperatures.append(temp)
        if temperatures.count > windowSize {
            temperatures.removeFirst()
        }
        return temperatures.reduce(0, +) / Double(temperatures.count)
    }
}

//Usage
let thirdPartyService = ThirdPartyWeatherService()
let adapter = WeatherServiceAdapter(service: thirdPartyService)

// Client code
func processWeatherData(weatherData: WeatherData) {
    let temp = weatherData.getTemperature()
    print("Current Temperature: \(temp)")
}

processWeatherData(weatherData: adapter)
// Should print current temperature and its moving average
