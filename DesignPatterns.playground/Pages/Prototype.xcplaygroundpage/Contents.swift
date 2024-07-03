/*
  Real-world examples of the Prototype pattern:

 Graphics Software:
 In applications like Photoshop or Illustrator, complex objects (like layers with multiple elements) can be cloned to create variations without rebuilding from scratch.
 Game Development:
 When creating enemies or obstacles, a game might use prototypes to spawn variations of base objects quickly, saving processing power and memory.
 Configuration Management:
 Systems that need to create multiple instances of complex, slightly varying configurations (like network settings) can use prototypes as starting points.
 Browser Tab Cloning:
 When you duplicate a tab in a web browser, it's essentially cloning the existing tab object with all its properties.
 Object Caching:
 Database systems might keep prototypes of frequently used objects to clone them rather than reconstructing from the database each time.
 GUI Builders:
 Interface design tools often use prototypes to create copies of UI elements that can be customized.
 Virtual Machine Templates:
 Cloud computing services use VM templates as prototypes to quickly spin up new instances with predefined configurations.

 Prototype Pattern Summary:
 The Prototype pattern is a creational design pattern that allows you to copy existing objects without making your code dependent on their classes. The main ideas are:

 Purpose: To create new objects by copying an existing object, known as the prototype.
 Structure:

 Prototype: An interface declaring the cloning method.
 Concrete Prototype: A class implementing the cloning method.
 Client: Creates a new object by asking a prototype to clone itself.


 Key Concepts:

 Cloning: The process of creating an exact copy of an existing object.
 Shallow vs Deep Copy: Decide whether to copy referenced objects.


 Benefits:

 Reduces subclassing for object creation.
 Allows adding/removing products at runtime.
 Specifies new objects by varying values.
 Reduces the need for factory classes.


 Drawbacks:

 Cloning complex objects with circular references can be tricky.
 Deep copying might be challenging for some object structures.


 Use When:

 Classes to instantiate are specified at runtime.
 Avoiding building a class hierarchy of factories.
 Instances of a class can have only a few different combinations of state.



 In essence, the Prototype pattern provides a mechanism for object copying, which can be particularly useful when the cost of creating a new object is more expensive than copying an existing one, or when you need to keep the number of classes in a system to a minimum while allowing for extensibility.
 
 Now that we've covered the implementation details, let's summarize the key points about the Prototype pattern:

 The Prototype pattern allows you to create new objects by copying existing objects (prototypes) without depending on their specific classes.
 
 It's particularly useful when:

 The cost of creating a new object is more expensive than copying an existing one.
 You want to hide the complexity of creating new instances from the client.
 You need to create objects whose type is determined at runtime.

 In your implementation, the DocumentManager acts as a prototype registry, storing and managing the prototypes.
 The use of failable initializers and optional return types in the clone() method allows for more robust error handling and safer type casting.
 This pattern promotes flexibility in your code, as new types of documents can be added to the system without changing the client code that uses DocumentManager.


 
Problem 5: Document Cloning System using Prototype Pattern

Description:
You're developing a document management system that needs to create copies of various types of documents (e.g., Text Documents, Spreadsheets, and Presentations). Implement a Document prototype that can create clones of these documents using the Prototype pattern.

Requirements:
1. Create a Cloneable protocol with a `clone() -> Cloneable` method.
   Why: This provides a common interface for all objects that can be cloned, allowing for type-agnostic cloning operations.

2. Create a Document protocol that inherits from Cloneable and has properties for name and content.
   Why: This defines the common structure for all document types, ensuring consistency across different document implementations.

3. Implement concrete classes for TextDocument, Spreadsheet, and Presentation that conform to the Document protocol.
   Why: These represent the specific document types that the system needs to handle, each with potentially unique properties or behaviors.

4. Each concrete class should implement the clone() method to create a deep copy of itself.
   Why: Deep copying ensures that modifying a cloned document doesn't affect the original, which is crucial for maintaining data integrity in a document management system.

5. Implement a DocumentManager class that stores prototype documents and creates new documents by cloning these prototypes.
   Why: This centralizes the management of document prototypes and provides a single point of access for creating new documents, simplifying the overall system architecture.

Example usage:
[Example usage remains the same]

Implement the Prototype pattern and related classes that satisfy these requirements.

After implementing the solution, be prepared to discuss:
1. Real-world applications of the Prototype pattern
2. Advantages of using the Prototype pattern in this scenario
3. Potential drawbacks or limitations of the Prototype pattern

What is the Prototype design pattern?
[You'll answer this after implementing the solution]
*/

protocol Cloneable {
    func clone() -> Self?
}

protocol Document: Cloneable {
    var name: String { get set }
    var content: String { get set }
}

class TextDocument: Document {
    var name: String
    var content: String
    
    init() {
        name = ""
        content = ""
    }
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
    
    init?(copying: Document) {
        self.name = copying.name
        self.content = copying.content
    }
    
    func clone() -> Self? {
        return TextDocument(copying: self) as? Self
    }
    
}

class Spreadsheet: Document {
    var name: String
    var content: String
    
    init() {
        name = ""
        content = ""
    }
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
    
    // Failable initializer
    init?(copying: Spreadsheet) {
        self.name = copying.name
        self.content = copying.content
    }
    
    func clone() -> Self? {
        return Spreadsheet(copying: self) as? Self
    }
    
}

class Presentation: Document {
    var name: String
    var content: String
    
    init() {
        name = ""
        content = ""
    }
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
    
    init?(copying: Presentation) {
        self.name = copying.name
        self.content = copying.content
    }
    
    func clone() -> Self? {
        return Presentation(copying: self) as? Self
    }
    
}

class DocumentManager {
    
    private var prototypes:[String: Document] = [:]
    
    func addPrototype(name:String, prototype: Document) {
        self.prototypes[name] = prototype
    }
    
    func createDocument(name: String) -> Document? {
        return self.prototypes[name]?.clone() as? Document
    }
    
}

                                                                  
//Example
let manager = DocumentManager()

let textDoc = TextDocument(name: "Report", content: "This is a report")
manager.addPrototype(name: "text", prototype: textDoc)

let spreadsheet = Spreadsheet(name: "Budget", content: "Financial data")
manager.addPrototype(name: "spreadsheet", prototype: spreadsheet)

if let newTextDoc = manager.createDocument(name: "text") as? TextDocument {
    newTextDoc.name = "New Report"
    print(newTextDoc.name) // Should print: "New Report"
    print(newTextDoc.content) // Should print: "This is a report"
}
