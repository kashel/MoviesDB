//
//  Created by Ireneusz Sołek
//  

import Foundation

class MovieListViewModel {
  struct StateData {
    var movies: [Movie] = []
    var currentPage: Int = 0
    var totalPages: Int = 0
    var phrase: String? = nil
  }
  
  enum State {
    case popularMovies
    case searchResults
  }
  
  enum Actions {
    case dataLoaded
  }
  
  private var currentState: State = .popularMovies
  private var stateData: [State: StateData] = [.popularMovies: .init(),
                                               .searchResults: .init()]
  private let loader: MoviesLoader
  var actions: ((Actions) -> Void)?
  
  init(loader: MoviesLoader = NetworkMoviesLoader(useCache: true)) {
    self.loader = loader
  }
  
  func loadMore() {
    let currentPage = currentStateData.currentPage
    if case .popularMovies = currentState {
      loader.load(page: currentPage + 1) { [weak self] (result) in
        guard let self = self else { return }
        self.onResult(result)
      }
      return
    }
    if case .searchResults = currentState {
      guard let phrase = stateData[currentState]!.phrase else { return }
      loader.search(phrase: phrase, page: currentPage + 1) { [weak self] (result) in
        guard let self = self else { return }
        self.onResult(result)
      }
    }
  }
  
  var movies: [Movie] {
    currentStateData.movies
  }
  
  var rowsCount: Int {
    hasMoreDataToLoad ? movies.count + 1 : movies.count
  }
  
  var hasMoreDataToLoad: Bool {
    currentStateData.totalPages > currentStateData.currentPage
  }
  
  private var currentStateData: StateData {
    stateData[currentState]!
  }
  
  private func onResult(_ result: Result<MoviesPage, MoviesLoaderError>) {
      switch result {
        case .failure(let error):
          print(error)
        case .success(let page):
          self.stateData[self.currentState]!.currentPage += 1
          self.stateData[self.currentState]!.movies.append(contentsOf: page.movies)
          self.stateData[self.currentState]!.totalPages = page.totalPages
          self.actions?(.dataLoaded)
      }
  }
  
  func search(phrase: String?) {
    if let phrase = phrase, phrase.count >= 1 {
      currentState = .searchResults
      stateData[.searchResults] = .init(movies: [], currentPage: 0, totalPages: 0, phrase: phrase)
      return
    }
    currentState = .popularMovies
    stateData[.searchResults] = .init()
  }
}
