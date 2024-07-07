import UIKit

// MARK: - Entity
struct MenuItem {
    let id: String
    let name: String
    let price: Double
}

// MARK: - Interactor
protocol MenuInteractorProtocol: AnyObject {
    func fetchMenuItems()
    func placeOrder(for itemId: String)
}

class MenuInteractor: MenuInteractorProtocol {
    weak var presenter: MenuPresenterProtocol?
    
    func fetchMenuItems() {
        // Simulate API call
        let items = [
            MenuItem(id: "1", name: "Burger", price: 5.99),
            MenuItem(id: "2", name: "Pizza", price: 8.99),
            MenuItem(id: "3", name: "Salad", price: 4.99)
        ]
        presenter?.interactor(didFetchItems: items)
    }
    
    func placeOrder(for itemId: String) {
        // Simulate order placement
        presenter?.interactor(didPlaceOrder: itemId)
    }
}

// MARK: - Presenter
protocol MenuPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectItem(id: String)
    func interactor(didFetchItems items: [MenuItem])
    func interactor(didPlaceOrder itemId: String)
}

class MenuPresenter: MenuPresenterProtocol {
    weak var view: MenuViewProtocol?
    var interactor: MenuInteractorProtocol?
    var router: MenuRouterProtocol?
    
    func viewDidLoad() {
        interactor?.fetchMenuItems()
    }
    
    func didSelectItem(id: String) {
        interactor?.placeOrder(for: id)
    }
    
    func interactor(didFetchItems items: [MenuItem]) {
        let displayItems = items.map { "\($0.name) - $\($0.price)" }
        view?.display(items: displayItems)
    }
    
    func interactor(didPlaceOrder itemId: String) {
        view?.showOrderConfirmation(for: itemId)
        router?.navigateToOrderConfirmation()
    }
}

// MARK: - View
protocol MenuViewProtocol: AnyObject {
    func display(items: [String])
    func showOrderConfirmation(for itemId: String)
}

class MenuViewController: UIViewController, MenuViewProtocol, UITableViewDataSource, UITableViewDelegate {
    var presenter: MenuPresenterProtocol?
    private let tableView = UITableView()
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
    }
    
    func display(items: [String]) {
        self.items = items
        tableView.reloadData()
    }
    
    func showOrderConfirmation(for itemId: String) {
        print("Order confirmed for item: \(itemId)")
    }
    
    // UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectItem(id: String(indexPath.row + 1))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Router
protocol MenuRouterProtocol: AnyObject {
    func navigateToOrderConfirmation()
}

class MenuRouter: MenuRouterProtocol {
    weak var viewController: UIViewController?
    
    func navigateToOrderConfirmation() {
        // In a real app, this would navigate to a new view controller
        print("Navigating to order confirmation screen")
    }
}

// MARK: - Module Builder
class MenuModuleBuilder {
    static func build() -> UIViewController {
        let view = MenuViewController()
        let interactor = MenuInteractor()
        let presenter = MenuPresenter()
        let router = MenuRouter()
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        router.viewController = view
        
        return view
    }
}

// Usage
let menuViewController = MenuModuleBuilder.build()
// Present this view controller in your app
