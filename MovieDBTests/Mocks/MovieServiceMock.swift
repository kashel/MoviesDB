//
//  Created by Ireneusz Sołek
//  

import Foundation
@testable import MovieDB

class MovieServiceMock: LoadMoviesService, SearchMoviesService {
  enum LoadFunctionCalled {
    case no
    case yes(page: Int)
  }
  
  var loadFunctionCalled: LoadFunctionCalled = .no
  var loadResult: Result<MoviesPage, MoviesLoaderError>? = nil
  func load(page: Int, completed: @escaping LoadMoviesService.Completed) {
    loadFunctionCalled = .yes(page: page)
    guard let loadResult = loadResult else { return }
    completed(loadResult)
  }
  
  enum SearchFunctionCalled {
    case no
    case yes(page: Int, phrase: String)
  }
  var searchFunctionCalled: SearchFunctionCalled = .no
  var searchResult: Result<MoviesPage, MoviesLoaderError>? = nil
  func search(phrase: String, page: Int, completed: @escaping SearchMoviesService.Completed) {
    searchFunctionCalled = .yes(page: page, phrase: phrase)
    guard let searchResult = searchResult else { return }
    completed(searchResult)
  }
}
