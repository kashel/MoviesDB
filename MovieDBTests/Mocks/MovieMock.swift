//
//  Created by Ireneusz Sołek
//  

@testable import MovieDB

extension Movie {
  static func mock(title: String) -> Movie {
    Movie(title: title, imageUrl: nil, overview: "", releaseDate: nil)
  }
}
