//
//  Created by Ireneusz Sołek
//  

import Foundation

class NetworkMoviesService: MoviesService {
  private let mapper = MovieMapper()
  private let useLoadCache: Bool
  private let useSearchCache: Bool
  private let loadCache = LoadMoviesCache()
  private let searchCache = SearchMoviesCache()
  
  init(useLoadCache: Bool, useSearchCache: Bool) {
    self.useLoadCache = useLoadCache
    self.useSearchCache = useSearchCache
  }
  
  enum QueryParam: String {
    case apiKey = "api_key"
    case sort = "sort_by"
    case page
    case query = "query"
  }

  private let baseUrl = "https://api.themoviedb.org/"
  private let imageUrl = "https://image.tmdb.org/t/p/w300/"
  private let apiKey = "1cc33b07c9aa5466f88834f7042c9258"
  
  
  func load(page: Int, completed: @escaping (Result<MoviesPage, MoviesLoaderError>) -> Void) {
    let url = makeDiscoverURL(page: page)
    fetch(url: url) { [weak self] (result) in
      guard let self = self, self.useLoadCache else {
        completed(result)
        return
      }
      switch result {
      case .failure(let error) where error == .noData:
        self.loadCache.load(page: page, completed: completed)
      case .success(let moviesPage):
        self.loadCache.cache(moviesPage: moviesPage)
        completed(result)
      default:
        completed(result)
      }
    }
  }
  
  func search(phrase: String, page: Int, completed: @escaping (Result<MoviesPage, MoviesLoaderError>) -> Void) {
    let url = makeSearchURL(phrase: phrase, page: page)
    fetch(url: url) { [weak self] (result) in
      guard let self = self, self.useSearchCache else {
        completed(result)
        return
      }
      switch result {
      case .failure(let error) where error == .noData:
        self.searchCache.search(phrase: phrase, page: page, completed: completed)
      case .success(let moviesPage):
        self.searchCache.cache(moviesPage: moviesPage, phrase: phrase)
        completed(result)
      default:
        completed(result)
      }
    }
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
