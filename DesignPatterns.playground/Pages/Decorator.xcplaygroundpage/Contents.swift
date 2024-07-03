/*
 What is the Decorator design pattern?
 The Decorator pattern is a structural design pattern that allows behavior to be added to individual objects, either statically or dynamically, without affecting the behavior of other objects from the same class. It's used to extend or alter the functionality of objects at runtime by wrapping them in an object of a decorator class.
 Real-world applications in e-commerce:

 Customizable products (as demonstrated)
 Order processing pipelines with optional steps
 Dynamic UI component styling
 Configurable shipping options

 Advantages in this scenario:

 Allows for flexible combination of add-ons
 Makes it easy to add new types of add-ons
 Avoids the need for a complex class hierarchy to represent all possible combinations

 Potential drawbacks:

 Can result in many small classes, which might be harder to manage
 The order of decorators can affect the result, which might be confusing
 Can complicate the process of instantiating the component

 Compared to other solutions:

 More flexible than using inheritance to create all possible combinations
 More maintainable than using a single class with conditional logic for all possible add-ons
 Allows for runtime configuration, unlike a static inheritance-based approach
*/

/*
Problem 9: Customizable Product Options using Decorator Pattern

Description:
You're developing an e-commerce platform for a coffee shop that allows customers to order custom coffee drinks. Each coffee can have various add-ons (e.g., extra shot, milk, syrup) that affect the final price and description of the drink. The system should be flexible enough to allow any combination of add-ons and easy addition of new add-ons in the future.

Why Decorator Pattern?
The Decorator pattern is suitable for this scenario because:
1. We need to add responsibilities (add-ons) to objects (coffee drinks) dynamically.
2. We want to provide a flexible alternative to subclassing for extending functionality.
3. We need to be able to combine add-ons in any order and quantity.

Requirements:
1. Create a Coffee protocol with methods getDescription() -> String and getPrice() -> Double.
   Why: This defines the interface for all coffee drinks and add-ons.

2. Implement a BasicCoffee class conforming to the Coffee protocol.
   Why: This represents the base coffee drink without any add-ons.

3. Create an AddOn class that conforms to Coffee and has a reference to another Coffee object.
   Why: This is the base decorator class that wraps a Coffee object.

4. Implement concrete AddOn classes for various add-ons (e.g., ExtraShot, Milk, Syrup).
   Why: These represent specific add-ons that can be applied to a coffee.

5. Each AddOn should modify the description and price of the coffee it decorates.
   Why: This demonstrates how decorators add responsibilities to the objects they wrap.

6. Implement a method to calculate the total calories of a coffee with its add-ons.
   Why: This shows how decorators can add new functionality not present in the original interface.

Example usage:
let myCoffee: Coffee = BasicCoffee()
print(myCoffee.getDescription()) // "Basic Coffee"
print(myCoffee.getPrice()) // 2.0

let coffeeWithMilk = Milk(coffee: myCoffee)
print(coffeeWithMilk.getDescription()) // "Basic Coffee, Milk"
print(coffeeWithMilk.getPrice()) // 2.5

let fancyCoffee = Syrup(coffee: ExtraShot(coffee: Milk(coffee: BasicCoffee())))
print(fancyCoffee.getDescription()) // "Basic Coffee, Milk, Extra Shot, Syrup"
print(fancyCoffee.getPrice()) // 4.0

Implement the Decorator pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. Real-world applications of the Decorator pattern in e-commerce systems
2. Advantages of using the Decorator pattern in this scenario
3. Potential drawbacks or limitations of the Decorator pattern
4. How the Decorator pattern compares to other potential solutions for this product customization problem

What is the Decorator design pattern?
[You'll answer this after implementing the solution]
*/

protocol Coffee {
    func getDescription() -> String
    func getPrice() -> Double
    func getCalories() -> Double
}

class BasicCoffee: Coffee {
    private let price: Double = 3.0
    
    func getDescription() -> String {
        return "Basic Coffee"
    }
    
    func getPrice() -> Double {
        return price
    }
    
    func getCalories() -> Double {
        return 150
    }
}

class AddOn: Coffee {
    private let coffee: Coffee
    private let addOnPrice: Double
    private let addOnDescription: String
    private let addedCalories: Double
    
    init(coffee: Coffee, addOnPrice: Double, addOnDescription: String, addedCalories: Double) {
        self.coffee = coffee
        self.addOnPrice = addOnPrice
        self.addOnDescription = addOnDescription
        self.addedCalories = addedCalories
    }
    
    func getDescription() -> String {
        return coffee.getDescription() + ", " + addOnDescription
    }
    
    func getPrice() -> Double {
        return coffee.getPrice() + addOnPrice
    }
    
    func getCalories() -> Double {
        return coffee.getCalories() + addedCalories
    }
}

class ExtraShot: AddOn {
    init(coffee: Coffee) {
        super.init(coffee: coffee, addOnPrice: 1.5, addOnDescription: "ExtraShot", addedCalories: 20)
    }
}

class Milk: AddOn {
    init(coffee: Coffee) {
        super.init(coffee: coffee, addOnPrice: 1.0, addOnDescription: "Milk", addedCalories: 10)
    }
}

class Syrup: AddOn {
    init(coffee: Coffee) {
        super.init(coffee: coffee, addOnPrice: 0.5, addOnDescription: "Syrup", addedCalories: 50)
    }
}

//Requirements:
//6. Implement a method to calculate the total calories of a coffee with its add-ons.
//   Why: This shows how decorators can add new functionality not present in the original interface.
//

let myCoffee: Coffee = BasicCoffee()
print(myCoffee.getDescription()) // "Basic Coffee"
print(myCoffee.getPrice()) // 2.0
print(myCoffee.getCalories())

let coffeeWithMilk = Milk(coffee: myCoffee)
print(coffeeWithMilk.getDescription()) // "Basic Coffee, Milk"
print(coffeeWithMilk.getPrice()) // 2.5
print(coffeeWithMilk.getCalories())

let fancyCoffee = Syrup(coffee: ExtraShot(coffee: Milk(coffee: BasicCoffee())))
print(fancyCoffee.getDescription()) // "Basic Coffee, Milk, Extra Shot, Syrup"
print(fancyCoffee.getPrice()) // 4.0
print(fancyCoffee.getCalories())
