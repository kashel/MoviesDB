//
//  Created by Ireneusz Sołek
//  

import XCTest
@testable import MovieDB

class MovieListViewModelTests: XCTestCase {
  private var sut: MovieListViewModel!
  private var movieServiceMock: MovieServiceMock!
  
  let loadMoviesMock: [Movie] = [.mock(title: "popular_1"), .mock(title: "popular_2"), .mock(title: "popular_3")]
  let searchMoviesMock: [Movie] = [.mock(title: "search_1"), .mock(title: "search_2"), .mock(title: "search_2")]
  
  override func setUp() {
    movieServiceMock = MovieServiceMock()
    movieServiceMock.loadResult = .success(MoviesPage(movies: loadMoviesMock, currentPage: 1, totalPages: 10))
    movieServiceMock.searchResult = .success(MoviesPage(movies: searchMoviesMock, currentPage: 1, totalPages: 10))
    sut = MovieListViewModel(moviesService: movieServiceMock)
  }
  
  func test_initialLoad_shouldFetchPopularMovies() {
    sut.loadMore()
    guard case .yes = movieServiceMock.loadFunctionCalled else {
      XCTFail()
      return
    }
  }
  
  func test_initialLoad_shouldFetchPopularMoviesForTheFirstPage() {
    sut.loadMore()
    guard case .yes(let page) = movieServiceMock.loadFunctionCalled else {
      XCTFail()
      return
    }
    XCTAssertEqual(page, 1)
  }
  
  func test_followingLoads_shouldFetchNextPage() {
    sut.loadMore()
    sut.loadMore()
    guard case .yes(let page) = movieServiceMock.loadFunctionCalled else {
      XCTFail()
      return
    }
    XCTAssertEqual(page, 2)
  }
  
  func test_exposedModels_containFetchingResult() {
    sut.loadMore()
    for (index, movie) in sut.movies.enumerated() {
      XCTAssertEqual(loadMoviesMock[index].title, movie.title)
    }
  }
  
  func test_loadingMoviesForSearchPhrase_shouldFetchSearchMovies() {
    sut.search(phrase: "test")
    sut.loadMore()
    guard case .yes(_, let phrase) = movieServiceMock.searchFunctionCalled else {
      XCTFail()
      return
    }
    XCTAssertEqual(phrase, "test")
  }
  
  func test_exposedModelsForSearchPhrase_containSearchResult() {
    sut.search(phrase: "test")
    sut.loadMore()
    for (index, movie) in sut.movies.enumerated() {
      XCTAssertEqual(searchMoviesMock[index].title, movie.title)
    }
  }
}
