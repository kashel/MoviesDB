//
//  Created by Ireneusz Sołek
//  

import Foundation

enum MoviesLoaderError: Error {
  case parsing
  case noData
}

protocol MoviesLoader {
  typealias Completed = (Result<[Movie], MoviesLoaderError>) -> Void
  func load(page: Int, completed: @escaping Completed)
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
  }
  
  //https://api.themoviedb.org/3/discover/movie?api_key=1cc33b07c9aa5466f88834f7042c9258&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=2&with_watch_monetization_types=flatrate
  private let baseUrl = "https://api.themoviedb.org/"
  private let imageUrl = "https://image.tmdb.org/t/p/w300/"
  private let apiKey = "1cc33b07c9aa5466f88834f7042c9258"
  
  func load(page: Int, completed: @escaping (Result<[Movie], MoviesLoaderError>) -> Void) {
    let url = makeDiscoverURL(page: page)
    
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
      
      let movies = moviesDTO.movies.map{self.mapper.map($0, imageBaseUrl: self.imageUrl)}
      completed(.success(movies))
    }
    task.resume()
  }
  
  
  private func makeDiscoverURL(page: Int) -> URL {
    constructURL(path: "/3/discover/movie", params: makeDiscoverParams(page: page))
  }
  
  private func makeDiscoverParams(page: Int) -> [QueryParam: String] {
    return [.apiKey: apiKey,
            .page: String(page),
            .sort: "popularity.desc"
            ]
  }
  
  func constructURL(path: String, params: [QueryParam: String]) -> URL {
    let queryItems = params.map{ URLQueryItem(name: $0.key.rawValue, value: $0.value)}
    var urlComponents = URLComponents(string: baseUrl)!
    urlComponents.path = path
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }
}
