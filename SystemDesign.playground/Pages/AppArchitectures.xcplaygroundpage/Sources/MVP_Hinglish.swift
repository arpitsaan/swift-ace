/*
 Theek hai, chalo MVP ke baare mein Hinglish mein baat karte hain, jaise main aapka teacher hoon.

 Dekho beta, ye MVP jo hai na, ye ek bahut smart tarika hai apne app ko organize karne ka. MVP ka matlab hai Model-View-Presenter. Ab main tumhe ek example se samjhata hoon.

 Socho ki tum ek restaurant chala rahe ho. Is restaurant mein teen important cheezein hoti hain:

 1. Model: Ye tumhara kitchen hai. Yahaan pe saara khana banta hai aur ingredients store hote hain. Ye data aur business logic ko handle karta hai.

 2. View: Ye tumhara dining area hai. Yahaan customers baithte hain aur khana dekhte aur khaate hain. Ye user interface hai, jo user ko dikhta hai.

 3. Presenter: Ye tumhara waiter hai. Waiter customers se baat karta hai, unka order leta hai, kitchen ko batata hai ki kya banana hai, aur phir khana laake customers ko deta hai.

 Ab samjho ki ek customer aaya aur usne menu maanga. Ye process MVP mein kaise hoga:

 1. View (Dining Area): Customer menu maangta hai. View bas itna karta hai ki Presenter ko bata deta hai "Arre bhai, customer ko menu chahiye".

 2. Presenter (Waiter): Presenter sochta hai "Accha, menu chahiye? Main kitchen se leke aata hoon". Phir wo Model se menu data maangta hai.

 3. Model (Kitchen): Model menu ka data Presenter ko de deta hai.

 4. Presenter (Waiter): Ab Presenter menu data ko acche se format karta hai, jaise ki price theek karke, available dishes mark karke.

 5. View (Dining Area): Finally, Presenter ye formatted menu View ko de deta hai, aur View use customer ko dikha deta hai.

 Is tarah se, har kaam ka ek clear responsibility hai:
 - View sirf dikhane ka kaam karta hai
 - Model sirf data aur logic ka kaam karta hai
 - Presenter in dono ke beech mein communicate karta hai aur decide karta hai ki kya karna hai

 Ye MVP ka fayda ye hai ki:
 1. Testing bahut easy ho jata hai, kyunki Presenter ko alag se test kar sakte hain.
 2. Code saaf aur organized rehta hai. Har cheez ka ek specific kaam hai.
 3. Agar design change karna ho, toh sirf View ko change karna padta hai, baaki sab same rehta hai.

 Toh beta, samajh mein aaya? MVP ek aisa tarika hai jisse tumhara app bilkul ek acche se chalne wale restaurant ki tarah smooth chalta hai. Har kisi ko pata hai ki uska kya kaam hai, aur sab mil julkar ek accha experience create karte hain.
 */

// Model
struct CalculatorModel {
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
}

// View Protocol
protocol CalculatorView: AnyObject {
    func displayResult(_ result: String)
}

// Presenter
class CalculatorPresenter {
    weak var view: CalculatorView?
    private let model = CalculatorModel()
    
    func addNumbers(_ a: String, _ b: String) {
        guard let num1 = Int(a), let num2 = Int(b) else {
            view?.displayResult("Error: Invalid input")
            return
        }
        
        let result = model.add(num1, num2)
        view?.displayResult("Result: \(result)")
    }
}

// View (UIViewController)
class CalculatorViewController: UIViewController, CalculatorView {
    let presenter = CalculatorPresenter()
    
    // Assume we have two UITextFields: numberTextField1 and numberTextField2
    // And a UIButton: calculateButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
    }
    
    @objc func calculateButtonTapped() {
        let number1 = numberTextField1.text ?? ""
        let number2 = numberTextField2.text ?? ""
        presenter.addNumbers(number1, number2)
    }
    
    func displayResult(_ result: String) {
        // Update UI to show result
        resultLabel.text = result
    }
}





Chalo, ab main is code ko samjhata hoon, bilkul simple tarike se:

Model:
swiftCopystruct CalculatorModel {
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
}
Ye humara "kitchen" hai. Isme sirf ek simple add function hai jo do numbers ko jodta hai.


View Protocol:
swiftCopyprotocol CalculatorView: AnyObject {
    func displayResult(_ result: String)
}
Ye ek contract hai jo kehta hai ki view mein ek displayResult function hona chahiye.


Presenter:
swiftCopyclass CalculatorPresenter {
    weak var view: CalculatorView?
    private let model = CalculatorModel()
    
    func addNumbers(_ a: String, _ b: String) {
        // ... (code)
    }
}
Ye humara "waiter" hai. Ye view se input leta hai, model se calculation karwata hai, aur phir result ko view pe dikhata hai.


View:
swiftCopyclass CalculatorViewController: UIViewController, CalculatorView {
    // ... (code)
}
Ye humara "dining area" hai. Ye user input leta hai aur result dikhata hai.



Ab dekho kaise kaam karta hai:

User jab calculate button dabata hai, to calculateButtonTapped() function call hota hai.
Ye function presenter ko numbers deta hai.
Presenter pehle check karta hai ki numbers sahi hain ya nahi.
Agar sahi hain, to presenter model se calculation karwata hai.
Phir presenter view ko result dikhane ke liye kehta hai.



Is tarah se:

View sirf user input lene aur result dikhane ka kaam karta hai.
Model sirf calculation ka kaam karta hai.
Presenter in dono ke beech mein communicate karta hai aur decide karta hai ki kya karna hai.

Ye simple example hai, lekin isse aap MVP ka basic structure samajh sakte hain. Real apps mein ye thoda aur complex ho sakta hai, lekin basic idea yahi rehta hai.
