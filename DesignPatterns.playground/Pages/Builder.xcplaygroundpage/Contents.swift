/*
 What is the Builder design pattern?
 The Builder design pattern is a creational pattern that separates the construction of a complex object from its representation. It allows you to create different representations of an object using the same construction process.
 
 Key components of the Builder pattern:

 Builder: An interface declaring product construction steps
 Concrete Builder: Implements the Builder interface to construct and assemble parts of the product
 Product: The complex object being built
 Director: Constructs an object using the Builder interface

 The Builder pattern is particularly useful when:

 The algorithm for creating a complex object should be independent of the parts that make up the object and how they're assembled
 The construction process must allow different representations for the object that's constructed
 You need fine control over the construction process

 ------
 Let's discuss the Builder pattern based on your implementation:

 Real-world applications of the Builder pattern:

 Complex object construction in software libraries and frameworks
 Configuring network requests in API clients
 Building complex database queries
 Creating documents with various formatting options (e.g., PDF generators)


 Advantages of using the Builder pattern in this scenario:

 Allows step-by-step construction of complex objects (pizzas)
 Encapsulates the way a complex object is constructed
 Allows different representations of the same construction process (e.g., different styles of pizzas)
 Provides better control over the construction process
 Separates the construction of a complex object from its representation


 Potential drawbacks or limitations of the Builder pattern:

 Can lead to more complex code, especially for simpler objects
 Requires creating multiple new classes (Builder interface and implementations)
 May be overkill for objects with few parameters
 
 -------
 In your pizza example, the Builder pattern allows for the flexible creation of different types of pizzas without complicating the Pizza class itself. It also makes it easy to introduce new types of pizzas or pizza styles by creating new Builder implementations.
 
 Overall, your implementation demonstrates a good understanding of the Builder pattern and its application in creating customizable, complex objects like gourmet pizzas.

 */




/*
Problem 4: Custom Pizza Order System using Builder Pattern

Description:
You're developing a pizza ordering system for a gourmet pizza restaurant. The restaurant offers highly customizable pizzas with various crusts, sauces, toppings, and cooking methods. Implement a PizzaBuilder that can create different types of custom pizzas using the Builder pattern.

Requirements:
1. Create a Pizza class with properties for crust, sauce, toppings, and cookingMethod.
2. Implement a PizzaBuilder protocol with methods for setting each pizza property and a build() method.
3. Create a concrete NYStylePizzaBuilder that implements the PizzaBuilder protocol.
4. Implement a PizzaDirector class that uses a PizzaBuilder to construct pizzas.
5. The director should have methods to construct preset pizzas (e.g., margherita, veggie supreme) and a method for custom pizzas.

Example usage:
let director = PizzaDirector(builder: NYStylePizzaBuilder())
let margherita = director.constructMargherita()
print(margherita.description)
// Should print: "NY Style Pizza with thin crust, tomato sauce, mozzarella and basil toppings, baked in a brick oven"

let customPizza = director.constructCustomPizza(crust: "thick", sauce: "bbq", toppings: ["chicken", "onions", "peppers"], cookingMethod: "grill")
print(customPizza.description)
// Should print: "NY Style Pizza with thick crust, bbq sauce, chicken, onions, and peppers toppings, cooked on a grill"

Implement the PizzaBuilder and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. Real-world applications of the Builder pattern
2. Advantages of using the Builder pattern in this scenario
3. Potential drawbacks or limitations of the Builder pattern

What is the Builder design pattern?
[You'll answer this after implementing the solution]
*/


class Pizza {
    var crust: String
    var sauce: String
    var toppings: Set<String>
    var cookingMethod: String
    
    init() {
        crust = ""
        sauce = ""
        toppings = []
        cookingMethod = ""
    }
}

extension Pizza: CustomDebugStringConvertible {
    
    var description: String {
        return self.debugDescription
    }
    
    var debugDescription: String {
        return "NY Style Pizza with \(self.crust), \(self.sauce), \(self.toppings), \(self.cookingMethod)"
    }

}


protocol PizzaBuilder {
    func chooseCrust(_ crust: String) -> PizzaBuilder
    func pickSauce(_ sauce: String) -> PizzaBuilder
    func chooseToppings(_ toppings: Set<String>) -> PizzaBuilder
    func selectCookingMethod(_ cookingMethod: String) -> PizzaBuilder
    
    func build() -> Pizza
}

class NYStylePizzaBuilder: PizzaBuilder {
    
    private var pizza: Pizza = Pizza()
    
    func chooseCrust(_ crust: String) -> PizzaBuilder {
        pizza.crust = crust
        return self
    }
    
    func pickSauce(_ sauce: String) -> PizzaBuilder {
        pizza.sauce = sauce
        return self
    }
    
    func chooseToppings(_ toppings: Set<String>) -> PizzaBuilder {
        pizza.toppings = toppings
        return self
    }
    
    func selectCookingMethod(_ cookingMethod: String) -> PizzaBuilder {
        pizza.cookingMethod = cookingMethod
        return self
    }
    
    func build() -> Pizza {
        return pizza
    }
}
            

class PizzaDirector {
    
    private var builder: PizzaBuilder
    
    init(builder: PizzaBuilder) {
        self.builder = builder
    }
    
    func constructMargherita() -> Pizza {
        builder.chooseCrust("Thin")
        builder.chooseToppings(["Basil"])
        builder.selectCookingMethod("Oven Baked")
        builder.pickSauce("Marinara")
        
        return builder.build()
    }
    
    func constructCustomPizza(crust: String, sauce: String, toppings: Set<String>, cookingMethod: String) -> Pizza {
        builder.chooseCrust(crust)
        builder.chooseToppings(toppings)
        builder.selectCookingMethod(cookingMethod)
        builder.pickSauce(sauce)
        
        return builder.build()
    }
}


                                                

//Example usage:
let director = PizzaDirector(builder: NYStylePizzaBuilder())
let margherita = director.constructMargherita()
print(margherita.description)
// Should print: "NY Style Pizza with thin crust, tomato sauce, mozzarella and basil toppings, baked in a brick oven"

let customPizza = director.constructCustomPizza(crust: "thick", sauce: "bbq", toppings: ["chicken", "onions", "peppers"], cookingMethod: "grill")
print(customPizza.description)
// Should print: "NY Style Pizza with thick crust, bbq sauce, chicken, onions, and peppers toppings, cooked on a grill"

