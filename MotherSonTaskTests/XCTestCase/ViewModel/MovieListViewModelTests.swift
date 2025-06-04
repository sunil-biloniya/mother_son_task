import XCTest
import Combine
@testable import MotherSonTask

final class MovieListViewModelTests: XCTestCase {
    // MARK: - Properties
    var sut: MovieListViewModel!
    var mockRepository: MockMovieRepository!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = MovieListViewModel(repository: mockRepository)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_init_shouldLoadPopularMovies() {
        // Given
        let expectation = expectation(description: "Load popular movies")
        mockRepository.mockPopularMovies = [
            Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0)
        ]
        
        // When
        sut.$movies
            .dropFirst()
            .sink { movies in
                // Then
                XCTAssertFalse(movies.isEmpty, "Should load popular movies")
                XCTAssertEqual(movies.count, 1, "Should load one movie")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_searchMovies_whenQueryIsEmpty_shouldLoadPopularMovies() {
        // Given
        let expectation = expectation(description: "Load popular movies")
        sut.searchQuery = ""
        mockRepository.mockPopularMovies = [
            Movie(id: 1, title: "Popular Movie", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0)
        ]
        
        // When
        sut.$movies
            .dropFirst()
            .sink { movies in
                // Then
                XCTAssertFalse(movies.isEmpty, "Should load popular movies")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_searchMovies_whenQueryIsValid_shouldLoadSearchResults() {
        // Given
        let expectation = expectation(description: "Load search results")
        let searchQuery = "test"
        mockRepository.mockSearchResults = [
            Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0)
        ]
        
        // When
        sut.searchQuery = searchQuery
        
        // Then
        sut.$movies
            .dropFirst()
            .sink { movies in
                XCTAssertEqual(movies.count, 1, "Should load search results")
                XCTAssertEqual(movies.first?.title, "Test Movie", "Should load correct movie")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_loadMoreMovies_shouldAppendMoreMovies() {
        // Given
        let expectation = expectation(description: "Load more movies")
        mockRepository.mockPopularMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0),
            Movie(id: 2, title: "Movie 2", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0)
        ]
        
        // When
        sut.loadMoreMovies()
        
        // Then
        sut.$movies
            .dropFirst()
            .sink { movies in
                XCTAssertEqual(movies.count, 2, "Should append more movies")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_toggleFavorite_shouldUpdateFavorites() {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0)
        
        // When
        sut.toggleFavorite(movie)
        
        // Then
        XCTAssertTrue(sut.favorites.contains(where: { $0.id == movie.id }), "Movie should be in favorites")
    }
    
    func test_resetSearch_shouldClearSearchAndLoadPopularMovies() {
        // Given
        let expectation = expectation(description: "Reset search")
        sut.searchQuery = "test"
        mockRepository.mockPopularMovies = [
            Movie(id: 1, title: "Popular Movie", overview: "Test", posterPath: nil, releaseDate: "2024", voteAverage: 8.0)
        ]
        
        // When
        sut.resetSearch()
        
        // Then
        sut.$movies
            .dropFirst()
            .sink { movies in
                XCTAssertEqual(sut.searchQuery, "", "Search query should be cleared")
                XCTAssertEqual(movies.count, 1, "Should load popular movies")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Mock Repository
class MockMovieRepository: MovieRepositoryProtocol {
    var mockPopularMovies: [Movie] = []
    var mockSearchResults: [Movie] = []
    var favorites: [Movie] = []
    
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        return Just(mockPopularMovies)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], Error> {
        return Just(mockSearchResults)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getFavorites() -> [Movie] {
        return favorites
    }
    
    func toggleFavorite(movie: Movie) {
        if favorites.contains(where: { $0.id == movie.id }) {
            favorites.removeAll { $0.id == movie.id }
        } else {
            favorites.append(movie)
        }
    }
} 