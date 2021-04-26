//
//  Created by Ireneusz Sołek
//  

import Foundation

struct Movie: Codable {
  let title: String
  let imageUrl: URL?
  let overview: String
  let releaseDate: Date?
}

struct MoviesPage: Codable {
  let movies: [Movie]
  let currentPage: Int
  let totalPages: Int
}
