import XCTest
import Combine
@testable import MotherSonTask

final class MovieListViewModelTests: XCTestCase {
    private var sut: MovieListViewModel!
    private var mockRepository: MockMovieRepository!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        mockRepository = MockMovieRepository()
        sut = MovieListViewModel(repository: mockRepository)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        cancellables = nil
    }
    
    // MARK: - Test Loading Popular Movies
    func testLoadPopularMoviesSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Load popular movies")
        let mockMovies = createMockMovies()
        mockRepository.mockPopularMovies = mockMovies
        
        // When
        sut.loadInitialData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.movies.count, mockMovies.count)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNil(self.sut.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadPopularMoviesFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Load popular movies failure")
        mockRepository.shouldFail = true
        
        // When
        sut.loadInitialData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.sut.movies.isEmpty)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNotNil(self.sut.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test Search Movies
    func testSearchMoviesSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Search movies")
        let mockMovies = createMockMovies()
        mockRepository.mockSearchResults = mockMovies
        
        // When
        sut.searchQuery = "test"
        sut.searchMovies()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.sut.movies.count, mockMovies.count)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNil(self.sut.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchMoviesEmptyQuery() {
        // Given
        let expectation = XCTestExpectation(description: "Search movies empty query")
        let mockMovies = createMockMovies()
        mockRepository.mockPopularMovies = mockMovies
        
        // When
        sut.searchQuery = ""
        sut.resetSearch()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.movies.count, mockMovies.count)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNil(self.sut.error)
            XCTAssertEqual(self.sut.movies, mockMovies)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Add test for search debounce
    func testSearchDebounce() {
        // Given
        let expectation = XCTestExpectation(description: "Search debounce")
        let mockMovies = createMockMovies()
        mockRepository.mockSearchResults = mockMovies
        
        // When
        sut.searchQuery = "test"
        sut.searchMovies()
        
        // Then
        // First verify that search hasn't happened immediately
        XCTAssertTrue(sut.movies.isEmpty)
        
        // Wait for debounce time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.sut.movies.count, mockMovies.count)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNil(self.sut.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Add test for search with multiple queries
    func testSearchWithMultipleQueries() {
        // Given
        let expectation = XCTestExpectation(description: "Search with multiple queries")
        let mockMovies1 = [createMockMovie(id: 1)]
        let mockMovies2 = [createMockMovie(id: 2)]
        
        // When
        sut.searchQuery = "query1"
        sut.searchMovies()
        
        // Change search results for second query
        mockRepository.mockSearchResults = mockMovies1
        
        // Wait for first search to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Change query and results
            self.sut.searchQuery = "query2"
            self.mockRepository.mockSearchResults = mockMovies2
            self.sut.searchMovies()
            
            // Wait for second search
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                XCTAssertEqual(self.sut.movies.count, mockMovies2.count)
                XCTAssertFalse(self.sut.isLoading)
                XCTAssertNil(self.sut.error)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Test Toggle Favorite
    func testToggleFavorite() {
        // Given
        let mockMovie = createMockMovie(id: 1)
        mockRepository.mockFavorites = [mockMovie]
        
        // When
        sut.loadFavorites()
        sut.toggleFavorite(mockMovie)
        
        // Then
        XCTAssertFalse(sut.favorites.contains(where: { $0.id == mockMovie.id }))
        XCTAssertFalse(mockRepository.favorites.contains(where: { $0.id == mockMovie.id }))
    }
    
    // MARK: - Helper Methods
    private func createMockMovie(id: Int) -> Movie {
        Movie(
            id: id,
            title: "Test Movie \(id)",
            overview: "Test Overview",
            posterPath: "/test.jpg",
            releaseDate: "2024-01-01",
            voteAverage: 8.5,
            isFavorite: false,
            voteCount: 100,
            popularity: 1000
        )
    }
    
    private func createMockMovies() -> [Movie] {
        [
            createMockMovie(id: 1),
            createMockMovie(id: 2),
            createMockMovie(id: 3)
        ]
    }
}

// MARK: - Mock Repository
private class MockMovieRepository: MovieRepositoryProtocol {
    var mockPopularMovies: [Movie] = []
    var mockSearchResults: [Movie] = []
    var mockFavorites: [Movie] = []
    var shouldFail = false
    
    var favorites: [Movie] {
        mockFavorites
    }
    
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        if shouldFail {
            return Fail(error: NSError(domain: "test", code: -1)).eraseToAnyPublisher()
        }
        return Just(mockPopularMovies)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], Error> {
        if shouldFail {
            return Fail(error: NSError(domain: "test", code: -1)).eraseToAnyPublisher()
        }
        return Just(mockSearchResults)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getFavorites() -> [Movie] {
        mockFavorites
    }
    
    func toggleFavorite(movie: Movie) {
        if let index = mockFavorites.firstIndex(where: { $0.id == movie.id }) {
            mockFavorites.remove(at: index)
        } else {
            mockFavorites.append(movie)
        }
    }
} 