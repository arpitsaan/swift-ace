/*
 "What is the Interpreter design pattern in the context of iOS development?":
 The Interpreter design pattern is a behavioral pattern that defines a grammatical representation for a language and provides an interpreter to deal with this grammar. In the context of iOS development:

 Purpose: It's used to evaluate language expressions or grammar for domain-specific languages within an application.
 Structure:

 Abstract Expression: Declares an interface for executing an operation (usually 'interpret').
 Terminal Expression: Implements the interpret operation for terminal symbols in the grammar.
 Non-terminal Expression: Implements the interpret operation for non-terminal symbols in the grammar.
 Context: Contains information global to the interpreter.
 Client: Builds the abstract syntax tree and invokes the interpret operation.


 Benefits:

 Flexibility: Allows easy modification and extension of the grammar.
 Separation of Concerns: Grammar rules are encapsulated in separate classes.
 Easy to Implement: For simple grammars, it's straightforward to implement and understand.


 iOS/Swift Application:

 In iOS, it's useful for parsing domain-specific languages, such as search queries, rule engines, or configuration settings.
 It aligns well with Swift's protocol-oriented programming, where the Expression can be defined as a protocol.


 Example Use Case:

 In an e-commerce app, it can be used to interpret discount rules, search queries, or product filtering criteria, allowing for dynamic and flexible rule creation without changing the app's core logic.


 Considerations:

 Complexity: For very complex grammars, the pattern can lead to a large number of classes.
 Performance: It may not be the most efficient for interpreting complex expressions.
 */
/*
Problem: Simple Discount Rule Interpreter for E-commerce App

Description:
You're developing an iOS e-commerce app that needs a flexible way to apply discount rules. You want to create a simple rule language that allows the marketing team to define discount conditions without changing the app's code. The app should be able to interpret these rules and apply discounts accordingly.

Why Interpreter Pattern?
The Interpreter pattern is suitable here because:
1. We need to evaluate a language with a defined grammar (discount rules).
2. The grammar is simple and can be represented as classes.
3. Rules may need to be changed frequently without app updates.

Requirements:
1. Define a `Rule` protocol that declares an `evaluate` method.
   Why: This provides a common interface for all rules in the language.

2. Implement basic rule classes:
   - `AmountRule`: Checks if the cart total is above/below a certain amount.
   - `ItemRule`: Checks if the number of items in the cart is above/below a certain count.
   Why: These represent the basic building blocks of discount rules.

3. Implement composite rule classes:
   - `AndRule`: Combines two rules with AND logic.
   - `OrRule`: Combines two rules with OR logic.
   Why: These allow for building complex rules from simpler ones.

4. Create a `Cart` struct to represent the current shopping cart.
   Why: This is the data model that the rules will operate on.

5. Create a `Interpreter` class that builds and evaluates the rule tree.
   Why: This provides a high-level interface for applying discount rules.

Example usage:
let cart = Cart(items: 3, total: 150.0)
let rule = "amount(>100) AND items(>=3)"
let interpreter = Interpreter()
let isEligible = interpreter.evaluate(rule: rule, cart: cart)
print(isEligible ? "10% discount applied!" : "No discount applicable.")

Implement the Interpreter pattern to solve this problem. After implementation, be prepared to discuss:
1. How does the Interpreter pattern compare to using hard-coded discount logic in the app?
2. In what other scenarios in an e-commerce app might the Interpreter pattern be useful?
3. How might this pattern be extended to support more complex discount rules or actions?

What is the Interpreter design pattern in the context of iOS development?
[You'll answer this after implementing the solution]
*/

// Implement your solution here
import Foundation

// Rule protocol
protocol Rule {
    func evaluate(cart: Cart) -> Bool
}

// Cart struct
struct Cart {
    let items: Int
    let total: Double
}

// Terminal expressions
class AmountRule: Rule {
    let amount: Double
    let comparison: (Double, Double) -> Bool
    
    init(_ comparison: @escaping (Double, Double) -> Bool, amount: Double) {
        self.comparison = comparison
        self.amount = amount
    }
    
    func evaluate(cart: Cart) -> Bool {
        return comparison(cart.total, amount)
    }
}

class ItemRule: Rule {
    let count: Int
    let comparison: (Int, Int) -> Bool
    
    init(_ comparison: @escaping (Int, Int) -> Bool, count: Int) {
        self.comparison = comparison
        self.count = count
    }
    
    func evaluate(cart: Cart) -> Bool {
        return comparison(cart.items, count)
    }
}

// Non-terminal expressions
class AndRule: Rule {
    let left: Rule
    let right: Rule
    
    init(_ left: Rule, _ right: Rule) {
        self.left = left
        self.right = right
    }
    
    func evaluate(cart: Cart) -> Bool {
        return left.evaluate(cart: cart) && right.evaluate(cart: cart)
    }
}

class OrRule: Rule {
    let left: Rule
    let right: Rule
    
    init(_ left: Rule, _ right: Rule) {
        self.left = left
        self.right = right
    }
    
    func evaluate(cart: Cart) -> Bool {
        return left.evaluate(cart: cart) || right.evaluate(cart: cart)
    }
}

// Interpreter
class Interpreter {
    func evaluate(rule: String, cart: Cart) -> Bool {
        let tokens = rule.components(separatedBy: " ")
        let parsedRule = parseRule(tokens: tokens)
        return parsedRule.evaluate(cart: cart)
    }
    
    private func parseRule(tokens: [String]) -> Rule {
        var rules: [Rule] = []
        var i = 0
        
        while i < tokens.count {
            if tokens[i] == "amount" {
                let comparison: (Double, Double) -> Bool = tokens[i+1] == ">" ? (>) : (<)
                let amount = Double(tokens[i+2])!
                rules.append(AmountRule(comparison, amount: amount))
                i += 3
            } else if tokens[i] == "items" {
                let comparison: (Int, Int) -> Bool = tokens[i+1] == ">=" ? (>=) : (<=)
                let count = Int(tokens[i+2])!
                rules.append(ItemRule(comparison, count: count))
                i += 3
            } else if tokens[i] == "AND" {
                i += 1
            } else if tokens[i] == "OR" {
                let left = combineRules(rules)
                rules = []
                i += 1
                let right = parseRule(tokens: Array(tokens[i...]))
                return OrRule(left, right)
            } else {
                i += 1
            }
        }
        
        return combineRules(rules)
    }

    private func combineRules(_ rules: [Rule]) -> Rule {
        guard !rules.isEmpty else {
            fatalError("No rules to combine")
        }
        
        if rules.count == 1 {
            return rules[0]
        }
        
        return rules.dropFirst().reduce(rules[0]) { AndRule($0, $1) }
    }
}

// Usage
let cart = Cart(items: 3, total: 150.0)
let rule = "amount(>100) AND items(>=3)"
let interpreter = Interpreter()
let isEligible = interpreter.evaluate(rule: rule, cart: cart)
print(isEligible ? "10% discount applied!" : "No discount applicable.")
