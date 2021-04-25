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
  let page: Int
  let movies: [MovieDTO]
  
  enum CodingKeys: String, CodingKey {
    case page
    case movies = "results"
  }
}

class MovieMapper {
  func map(_ dto: MovieDTO) -> Movie {
    let date = dateFormatter.date(from:dto.releaseDate ?? "")
    if (date == nil) {
      assertionFailure("server responded with data in unexpected format")
    }
    let imageURL = dto.image != nil ? URL(string: dto.image!) : nil
    return Movie(title: dto.title ?? "", imageUrl: imageURL, overview: dto.overview ?? "", releaseDate: date ?? Date())
  }
  
  private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
  }
}