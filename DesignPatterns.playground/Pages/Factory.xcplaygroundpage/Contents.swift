/*
Problem 2: Factory Method Pattern

Description:
Implement a VehicleFactory that can create different types of vehicles (Car, Motorcycle, and Truck) using the Factory Method pattern.

Requirements:
1. Create a Vehicle protocol with a method `drive()`.
2. Implement three classes that conform to the Vehicle protocol: Car, Motorcycle, and Truck.
3. Create a VehicleFactory protocol with a method `createVehicle(of type: VehicleType) -> Vehicle`.
4. Implement a ConcreteVehicleFactory that conforms to the VehicleFactory protocol.
5. Use an enum VehicleType to specify the type of vehicle to create.
 
 */

import Foundation

protocol Vehicle {
    func drive()
}

class Car: Vehicle {
    func drive() {
        print("La la la")
    }
}

class Motorcycle: Vehicle {
    func drive() {
        print("Vroom vroom")
    }
}

class Truck: Vehicle {
    func drive() {
        print("Horn ok please")
    }
}

enum VehicleType {
    case car
    case motorcycle
    case truck
}
     
protocol VehicleFactory {
    func createVehicle(of type: VehicleType) -> Vehicle
}


public class ConcreteVehicleFactory: VehicleFactory {
    
    func createVehicle(of type: VehicleType) -> Vehicle {
        switch type {
        case .car:
            return Car()
            
        case .motorcycle:
            return Motorcycle()
            
        case .truck:
            return Truck()
        }
    }
}




//Example:
let factory = ConcreteVehicleFactory()
let car = factory.createVehicle(of: .car)
car.drive() // Should print: "Driving a car"

let motorcycle = factory.createVehicle(of: .motorcycle)
motorcycle.drive() // Should print: "Riding a motorcycle"

let truck = factory.createVehicle(of: .truck)
truck.drive() // Should print: "Driving a truck"

//Implement the VehicleFactory and related classes that satisfy these requirements.
