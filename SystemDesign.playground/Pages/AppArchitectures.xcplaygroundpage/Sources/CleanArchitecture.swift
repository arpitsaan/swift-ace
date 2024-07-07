// MARK: - Entities (Core Business Objects)

struct MenuItem {
    let id: String
    let name: String
    let price: Double
}

struct Order {
    let id: String
    let items: [MenuItem]
    var totalAmount: Double {
        return items.reduce(0) { $0 + $1.price }
    }
}

// MARK: - Use Cases (Application Business Rules)

protocol MenuUseCase {
    func fetchMenuItems(completion: @escaping (Result<[MenuItem], Error>) -> Void)
}

protocol OrderUseCase {
    func placeOrder(items: [MenuItem], completion: @escaping (Result<Order, Error>) -> Void)
}

class MenuInteractor: MenuUseCase {
    private let menuRepository: MenuRepository
    
    init(menuRepository: MenuRepository) {
        self.menuRepository = menuRepository
    }
    
    func fetchMenuItems(completion: @escaping (Result<[MenuItem], Error>) -> Void) {
        menuRepository.fetchMenuItems(completion: completion)
    }
}

class OrderInteractor: OrderUseCase {
    private let orderRepository: OrderRepository
    
    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }
    
    func placeOrder(items: [MenuItem], completion: @escaping (Result<Order, Error>) -> Void) {
        let order = Order(id: UUID().uuidString, items: items)
        orderRepository.saveOrder(order, completion: completion)
    }
}

// MARK: - Interface Adapters

protocol MenuRepository {
    func fetchMenuItems(completion: @escaping (Result<[MenuItem], Error>) -> Void)
}

protocol OrderRepository {
    func saveOrder(_ order: Order, completion: @escaping (Result<Order, Error>) -> Void)
}

class MenuPresenter {
    weak var viewController: MenuViewControllerProtocol?
    private let menuUseCase: MenuUseCase
    
    init(menuUseCase: MenuUseCase) {
        self.menuUseCase = menuUseCase
    }
    
    func loadMenu() {
        menuUseCase.fetchMenuItems { [weak self] result in
            switch result {
            case .success(let menuItems):
                let viewModels = menuItems.map { MenuItemViewModel(name: $0.name, price: String(format: "%.2f", $0.price)) }
                self?.viewController?.displayMenu(viewModels)
            case .failure(let error):
                self?.viewController?.displayError(message: error.localizedDescription)
            }
        }
    }
}

struct MenuItemViewModel {
    let name: String
    let price: String
}

// MARK: - Frameworks and Drivers (External Interfaces)

class APIMenuRepository: MenuRepository {
    func fetchMenuItems(completion: @escaping (Result<[MenuItem], Error>) -> Void) {
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let menuItems = [
                MenuItem(id: "1", name: "Burger", price: 5.99),
                MenuItem(id: "2", name: "Pizza", price: 8.99),
                MenuItem(id: "3", name: "Salad", price: 4.99)
            ]
            completion(.success(menuItems))
        }
    }
}

class LocalOrderRepository: OrderRepository {
    func saveOrder(_ order: Order, completion: @escaping (Result<Order, Error>) -> Void) {
        // Simulate local storage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(order))
        }
    }
}

protocol MenuViewControllerProtocol: AnyObject {
    func displayMenu(_ items: [MenuItemViewModel])
    func displayError(message: String)
}

class MenuViewController: UIViewController, MenuViewControllerProtocol {
    private let presenter: MenuPresenter
    private var menuItems: [MenuItemViewModel] = []
    
    init(presenter: MenuPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadMenu()
    }
    
    func displayMenu(_ items: [MenuItemViewModel]) {
        self.menuItems = items
        // Update UI (e.g., tableView.reloadData())
    }
    
    func displayError(message: String) {
        // Show error alert
    }
}

// MARK: - Dependency Injection

class AppDIContainer {
    lazy var menuRepository: MenuRepository = APIMenuRepository()
    lazy var orderRepository: OrderRepository = LocalOrderRepository()
    
    func makeMenuUseCase() -> MenuUseCase {
        return MenuInteractor(menuRepository: menuRepository)
    }
    
    func makeOrderUseCase() -> OrderUseCase {
        return OrderInteractor(orderRepository: orderRepository)
    }
    
    func makeMenuPresenter() -> MenuPresenter {
        return MenuPresenter(menuUseCase: makeMenuUseCase())
    }
    
    func makeMenuViewController() -> MenuViewController {
        let presenter = makeMenuPresenter()
        let viewController = MenuViewController(presenter: presenter)
        presenter.viewController = viewController
        return viewController
    }
}

// Usage
let diContainer = AppDIContainer()
let menuViewController = diContainer.makeMenuViewController()
// Present this view controller in your app
