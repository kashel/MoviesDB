//
//  Created by Ireneusz Sołek
//  

import Foundation

class LoadMoviesCache: LoadMoviesService {
  let userDefaults: UserDefaults
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  
  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
  let userDefaultsKey = "popularMoviesCache"
  lazy var loadedCache: [Int: MoviesPage] = loadFromStorage()
  
  func load(page: Int, completed: @escaping Completed) {
    guard loadedCache.keys.contains(page) else {
      completed(.failure(.noData))
      return
    }
    completed(.success(loadedCache[page]!))
  }
  
  func cache(moviesPage: MoviesPage) {
      loadedCache[moviesPage.currentPage] = moviesPage
      save()
  }

  private func loadFromStorage() -> [Int: MoviesPage] {
    guard let data = userDefaults.object(forKey: userDefaultsKey) as? Data else {
      return [:]
    }
    guard let pages = try? decoder.decode([Int: MoviesPage].self, from: data) else {
      assertionFailure("Unable to decode saved data")
      return [:]
    }
    return pages
  }
  
  private func save() {
    guard let encoded = try? encoder.encode(loadedCache) else {
      assertionFailure("Unable to encode data for save")
      return
    }
    userDefaults.set(encoded, forKey: userDefaultsKey)
  }
}
