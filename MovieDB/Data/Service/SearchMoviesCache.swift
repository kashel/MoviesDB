//
//  Created by Ireneusz Sołek
//  

import Foundation

class SearchMoviesCache: SearchMoviesService {
  let userDefaults: UserDefaults
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  
  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
  let userDefaultsKey = "searchMoviesCache"
  lazy var loadedCache: [String: [Int: MoviesPage]] = loadFromStorage()
  
  func search(phrase: String, page: Int, completed: @escaping Completed) {
    guard let phraseCache = loadedCache[phrase], let cachedPage = phraseCache[page] else {
      completed(.failure(.noData))
      return
    }
    completed(.success(cachedPage))
  }
  
  func cache(moviesPage: MoviesPage, phrase: String) {
    var phraseCache = loadedCache[phrase] ?? [:]
    phraseCache[moviesPage.currentPage] = moviesPage
    loadedCache[phrase] = phraseCache
    save()
  }
  
  private func loadFromStorage() -> [String: [Int: MoviesPage]] {
    guard let data = userDefaults.object(forKey: userDefaultsKey) as? Data else {
      return [:]
    }
    guard let cache = try? decoder.decode([String: [Int: MoviesPage]].self, from: data) else {
      assertionFailure("Unable to decode saved data")
      return [:]
    }
    return cache
  }
  
  private func save() {
    guard let encoded = try? encoder.encode(loadedCache) else {
      assertionFailure("Unable to encode data for save")
      return
    }
    userDefaults.set(encoded, forKey: userDefaultsKey)
  }
}
