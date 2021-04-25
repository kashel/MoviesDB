//
//  Created by Ireneusz Sołek
//  

import Foundation

enum MoviesLoaderError: Error {
  case parsing
  case noData
}

protocol MoviesLoader {
  typealias Completed = (Result<MoviesPage, MoviesLoaderError>) -> Void
  func load(page: Int, completed: @escaping Completed)
  func search(phrase: String, page: Int, completed: @escaping (Result<MoviesPage, MoviesLoaderError>) -> Void)
}

class NetworkMoviesLoader: MoviesLoader {
  private let mapper = MovieMapper()
  private let useCache: Bool
  
  init(useCache: Bool) {
    self.useCache = useCache
  }
  
  enum QueryParam: String {
    case apiKey = "api_key"
    case sort = "sort_by"
    case page
    case query = "query"
  }
  
  //https://api.themoviedb.org/3/discover/movie?api_key=1cc33b07c9aa5466f88834f7042c9258&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=2&with_watch_monetization_types=flatrate
  private let baseUrl = "https://api.themoviedb.org/"
  private let imageUrl = "https://image.tmdb.org/t/p/w300/"
  private let apiKey = "1cc33b07c9aa5466f88834f7042c9258"
  
  
  func load(page: Int, completed: @escaping (Result<MoviesPage, MoviesLoaderError>) -> Void) {
    let url = makeDiscoverURL(page: page)
    fetch(url: url, completed: completed)
  }
  
  func search(phrase: String, page: Int, completed: @escaping (Result<MoviesPage, MoviesLoaderError>) -> Void) {
    let url = makeSearchURL(phrase: phrase, page: page)
    fetch(url: url, completed: completed)
  }
  
  private func fetch(url: URL, completed: @escaping (Result<MoviesPage, MoviesLoaderError>) -> Void) {
    let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {[weak self] (data, _, error) in
      guard let self = self else { return }
      
      guard error == nil, let data = data else {
        completed(.failure(.noData))
        return
      }
      
      guard let moviesDTO = try? JSONDecoder().decode(MoviesDTO.self, from: data) else {
        completed(.failure(.parsing))
        return
      }
      
      let page = self.mapper.map(dto: moviesDTO, imageBaseUrl: self.imageUrl)
      completed(.success(page))
    }
    task.resume()
  }
  
  private func makeSearchURL(phrase: String, page: Int) -> URL {
    let params: [QueryParam: String] = [.apiKey: apiKey,
                                        .query: phrase,
                                        .page: String(page),
                                        .sort: "popularity.desc"]
    return constructURL(path: "/3/search/movie", params: params)
  }
  
  private func makeDiscoverURL(page: Int) -> URL {
    let params: [QueryParam: String] = [.apiKey: apiKey,
                                        .page: String(page),
                                        .sort: "popularity.desc"]
    return constructURL(path: "/3/discover/movie", params: params)
  }
  
  func constructURL(path: String, params: [QueryParam: String]) -> URL {
    let queryItems = params.map{ URLQueryItem(name: $0.key.rawValue, value: $0.value)}
    var urlComponents = URLComponents(string: baseUrl)!
    urlComponents.path = path
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }
}
