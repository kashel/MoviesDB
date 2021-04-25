//
//  Created by Ireneusz Sołek
//  

import Foundation

struct MovieDTO: Decodable {
  let title: String?
  let image: String?
  let overview: String?
  let releaseDate: String?
  
  enum CodingKeys: String, CodingKey {
    case title
    case image = "poster_path"
    case overview
    case releaseDate = "release_date"
   }
}

struct MoviesDTO: Decodable {
  let page: Int?
  let totalPages: Int?
  let movies: [MovieDTO]
  
  enum CodingKeys: String, CodingKey {
    case page
    case movies = "results"
    case totalPages = "total_pages"
  }
}

class MovieMapper {
  func map(dto: MoviesDTO, imageBaseUrl: String) -> MoviesPage {
    let movies = dto.movies.map{ map($0, imageBaseUrl: imageBaseUrl) }
    return MoviesPage(movies: movies, currentPage: dto.page ?? 1, totalPages: dto.totalPages ?? 1)
  }
  
  private func map(_ dto: MovieDTO, imageBaseUrl: String) -> Movie {
    let date = dateFormatter.date(from:dto.releaseDate ?? "")
    let imageURL = dto.image != nil ? URL(string: imageBaseUrl + dto.image!) : nil
    return Movie(title: dto.title ?? "", imageUrl: imageURL, overview: dto.overview ?? "", releaseDate: date)
  }
  
  private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
  }
}
