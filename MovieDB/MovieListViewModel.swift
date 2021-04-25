//
//  Created by Ireneusz Sołek
//  

import Foundation

class MovieListViewModel {
  enum Actions {
    case dataLoaded(MoviesPage)
  }
  
  private var currentPage = 0
  private let loader: MoviesLoader
  var actions: ((Actions) -> Void)?
  
  init(loader: MoviesLoader = NetworkMoviesLoader(useCache: true)) {
    self.loader = loader
  }
  
  func loadMore() {
    loader.load(page: currentPage + 1) { [weak self] (result) in
      guard let self = self else { return }
      switch result {
        case .failure(let error):
          print(error)
        case .success(let page):
          self.currentPage += 1
          self.actions?(.dataLoaded(page))
      }
    }
  }
}
