//
//  Created by Ireneusz Sołek
//  

import Foundation

enum MoviesLoaderError: Error {
  case parsing
  case noData
}

protocol LoadMoviesService {
  typealias Completed = (Result<MoviesPage, MoviesLoaderError>) -> Void
  func load(page: Int, completed: @escaping Completed)
}

protocol SearchMoviesService {
  typealias Completed = (Result<MoviesPage, MoviesLoaderError>) -> Void
  func search(phrase: String, page: Int, completed: @escaping Completed)
}

typealias MoviesService = LoadMoviesService & SearchMoviesService
