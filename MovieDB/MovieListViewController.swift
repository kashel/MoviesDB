//
//  Created by Ireneusz Sołek
//  

import UIKit
import SDWebImage

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
  private var searchResults: [Movie] = []
  private var loadingCellActive = false
  
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
    tableView.register(MovieCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    tableView.dataSource = self
    self.tableView.delegate = self
    bindViewModel()
    viewModel.loadMore()
  }
  
  private func bindViewModel() {
    viewModel.actions = { [unowned self] action in
      switch action {
      case .dataLoaded(let page):
        self.loadingCellActive = page.totalPages > page.currentPage
        self.movies.append(contentsOf: page.movies)
        DispatchQueue.main.async {
          tableView.reloadData()
        }
      }
    }
  }
  
  private func setupView() {
    tableView.separatorStyle = .none
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
    if isSearching {
      return searchResults.count
    }
    return loadingCellActive ? movies.count + 1 : movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard !isLoadingCellIndexPath(indexPath) else {
      return LoadingCell()
    }
    let movie = findMovie(for: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as?  MovieCell else {
      return UITableViewCell()
    }
    cell.configure(with: MovieCellConfiguration(title: movie.title, imageURL: movie.imageUrl))
    return cell
  }
  
  private func findMovie(for indexPath: IndexPath) -> Movie {
    isSearching ? searchResults[indexPath.row] : movies[indexPath.row]
  }
}


extension MovieListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    tableView.reloadData()
  }
}

extension MovieListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      guard isLoadingCellIndexPath(indexPath) else { return }
      viewModel.loadMore()
  }
}

//MARK: - Pagination
extension MovieListViewController {
  private func isLoadingCellIndexPath(_ indexPath: IndexPath) -> Bool {
      guard !isSearching, loadingCellActive else { return false }
      return indexPath.row == movies.count
  }
}

//MARK: - Search bar

extension MovieListViewController {
  private var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  private var isSearching: Bool {
    return searchController.isActive && !isSearchBarEmpty
  }
}
