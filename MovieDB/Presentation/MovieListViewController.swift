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
      if case .fetchingFailed = action {
        self.presentAlertController()
      }
      DispatchQueue.main.async {
        tableView.reloadData()
      }
    }
  }
  
  private func presentAlertController() {
    DispatchQueue.main.async {
      let controller = UIAlertController(title: "Fetching failed", message: "Fetching data failed", preferredStyle: .alert)
      controller.addAction(.init(title: "ok", style: .cancel, handler: nil))
      controller.addAction(UIAlertAction(title: "retry", style: .default, handler: { [unowned self] (_) in
        self.viewModel.loadMore()
      }))
      self.present(controller, animated: true, completion: nil)
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

//MARK: - UITableViewDataSource
extension MovieListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.rowsCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard !isLoadingCellIndexPath(indexPath) else {
      return LoadingCell()
    }
    let movie = viewModel.movies[indexPath.row]
    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as?  MovieCell else {
      return UITableViewCell()
    }
    cell.configure(with: MovieCellConfiguration(title: movie.title, imageURL: movie.imageUrl))
    return cell
  }
}

//MARK: - UITableViewDelegate
extension MovieListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      guard isLoadingCellIndexPath(indexPath) else { return }
      viewModel.loadMore()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    coordinator?.showDetails(movie: viewModel.movies[indexPath.row])
  }
}

//MARK: - UISearchResultsUpdating
extension MovieListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchPhrase = searchController.searchBar.text
    viewModel.search(phrase: searchPhrase)
    if let searchPhrase = searchPhrase, searchPhrase.count > 0 {
      viewModel.loadMore()
    } else {
      tableView.reloadData()
    }
  }
}

//MARK: - Pagination
extension MovieListViewController {
  private func isLoadingCellIndexPath(_ indexPath: IndexPath) -> Bool {
      guard viewModel.hasMoreDataToLoad else { return false }
      return indexPath.row == viewModel.rowsCount - 1
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
