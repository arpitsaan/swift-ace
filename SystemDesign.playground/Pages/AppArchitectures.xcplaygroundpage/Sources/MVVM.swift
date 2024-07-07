import Foundation
import Combine

// Model
struct MenuItem {
    let name: String
    let price: Double
}

class MenuModel {
    func fetchMenuItems() -> [MenuItem] {
        // Imagine this fetches from a database
        return [
            MenuItem(name: "Burger", price: 5.99),
            MenuItem(name: "Pizza", price: 8.99),
            MenuItem(name: "Salad", price: 4.99)
        ]
    }
}

// ViewModel
class MenuViewModel: ObservableObject {
    @Published var menuItems: [String] = []
    private let model = MenuModel()
    
    func loadMenu() {
        let items = model.fetchMenuItems()
        menuItems = items.map { "\($0.name) - $\($0.price)" }
    }
    
    func placeOrder(for itemIndex: Int) {
        guard itemIndex < menuItems.count else { return }
        print("Order placed for: \(menuItems[itemIndex])")
    }
}

// SwiftUI View
import SwiftUI

struct MenuView: View {
    @StateObject var viewModel = MenuViewModel()
    
    var body: some View {
        List(viewModel.menuItems, id: \.self) { item in
            Text(item)
                .onTapGesture {
                    if let index = viewModel.menuItems.firstIndex(of: item) {
                        viewModel.placeOrder(for: index)
                    }
                }
        }
        .onAppear {
            viewModel.loadMenu()
        }
    }
}

// UIKit View
import UIKit
import Combine

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let viewModel = MenuViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
        viewModel.loadMenu()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
    }
    
    private func bindViewModel() {
        viewModel.$menuItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        cell.textLabel?.text = viewModel.menuItems[indexPath.row]
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.placeOrder(for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
