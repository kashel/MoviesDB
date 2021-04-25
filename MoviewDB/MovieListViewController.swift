//
//  Created by Ireneusz Sołek
//  

import UIKit

class MovieListViewController: UIViewController {
  struct Constants {
    static let cellReuseIdentifier = "cell"
    static let searchMovies = "Search Movies"
    static let popularMovies = "Popular Movies"
  }
  private weak var coordinator: MovieCoordinator?
  private let tableView = UITableView()
  private let searchController = UISearchController(searchResultsController: nil)
  private let viewModel = MovieListViewModel()
  private var movies: [Movie] = []
  
  init(coordinator: MovieCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    setupView()
  }
  
  private func setup() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    tableView.dataSource = self
    bindViewModel()
    viewModel.loadMore()
  }
  
  private func bindViewModel() {
    viewModel.actions = { [unowned self] action in
      switch action {
      case .dataLoaded(let newMovies):
        self.movies.append(contentsOf: newMovies)
        DispatchQueue.main.async {
          tableView.reloadData()
        }
      }
    }
  }
  
  private func setupView() {
    navigationItem.title = Constants.popularMovies
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = Constants.searchMovies
    navigationItem.searchController = searchController
    definesPresentationContext = true
    tableView.pinToSafeArea(of: view)
  }
}


extension MovieListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let movie = movies[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)
    var contentConfiguration = cell.defaultContentConfiguration()
    contentConfiguration.text = movie.title
    cell.contentConfiguration = contentConfiguration
    return cell
  }
}


extension MovieListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    
  }
}
