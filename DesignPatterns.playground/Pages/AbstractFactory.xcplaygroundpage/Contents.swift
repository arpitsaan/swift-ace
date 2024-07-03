/*
 What is the Abstract Factory design pattern?
 The Abstract Factory design pattern is a creational pattern that provides an interface for creating families of related or dependent objects without specifying their concrete classes. It encapsulates a group of individual factories that have a common theme.
 In essence, the Abstract Factory pattern allows you to create objects that follow a general pattern. It's particularly useful when your system needs to be independent of how its objects are created, composed, and represented, and when you want to provide a library of products without revealing their implementations.
 The pattern consists of several key components:

 Abstract Factory: Declares an interface for operations that create abstract product objects.
 Concrete Factory: Implements the operations to create concrete product objects.
 Abstract Product: Declares an interface for a type of product object.
 Concrete Product: Defines a product object to be created by the corresponding concrete factory and implements the Abstract Product interface.

 By using the Abstract Factory pattern, you can ensure that a family of related products work together seamlessly, which is particularly valuable in scenarios like cross-platform development or when dealing with multiple, interchangeable backend services.
 */


/*
Problem 3: Cross-Platform UI Component Factory using Abstract Factory Pattern

Description:
You're developing a cross-platform application that needs to create UI components (buttons and text fields) for different operating systems (iOS and Android). Implement an AbstractFactory that can create these UI components using the Abstract Factory pattern.

Requirements:
1. Create protocols for Button and TextField with a method `render() -> String`.
2. Implement concrete classes for iOS and Android versions of Button and TextField.
3. Create an AbstractFactory protocol with methods to create buttons and text fields.
4. Implement concrete factories for iOS and Android that conform to the AbstractFactory protocol.
5. Demonstrate the use of these factories to create UI components for different platforms.

What is the Abstract Factory design pattern?
[You'll answer this after implementing the solution]
*/


protocol UIElement {
    func render() -> String
}

protocol Button: UIElement {}

protocol TextField: UIElement {}

class iOSButton: Button {
    func render() -> String {
        return "Rendering iOS button"
    }
}

class AndroidButton: Button {
    func render() -> String {
        return "Rendering Android button"
    }
}

class iOSTextField: TextField {
    func render() -> String {
        return "Rendering iOS text field"
    }
}

class AndroidTextField: TextField {
    func render() -> String {
        return "Rendering Android text field"
    }
}


protocol AbstractFactory {
    func createButton() -> Button
    func createTextField() -> TextField
}

class iOSUIFactory: AbstractFactory {
    func createButton() -> Button {
        return iOSButton()
    }
    
    func createTextField() -> TextField {
        return iOSTextField()
    }
}

class AndroidUIFactory: AbstractFactory {
    func createButton() -> Button {
        return AndroidButton()
    }
    
    func createTextField() -> TextField {
        return AndroidTextField()
    }
}


//Example:
let iOSFactory = iOSUIFactory()
let iB = iOSFactory.createButton()
print(iB.render()) // Should print: "Rendering iOS button"

let androidFactory = AndroidUIFactory()
let androidTextField = androidFactory.createTextField()
print(androidTextField.render()) // Should print: "Rendering Android text field"

