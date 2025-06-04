import XCTest
import Combine
@testable import MotherSonTask

final class NetworkServiceTests: XCTestCase {
    // MARK: - Properties
    var sut: NetworkService!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = NetworkService(apiKey: "test_api_key")
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_fetch_whenURLIsValid_shouldReturnData() {
        // Given
        let expectation = expectation(description: "Fetch data")
        let endpoint = Endpoint.popularMovies(page: 1)
        
        // When
        sut.fetch(MovieResponse.self, endpoint: endpoint)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Fetch failed with error: \(error)")
                }
            } receiveValue: { response in
                // Then
                XCTAssertNotNil(response, "Response should not be nil")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_fetch_whenURLIsInvalid_shouldReturnError() {
        // Given
        let expectation = expectation(description: "Fetch error")
        let invalidEndpoint = Endpoint.custom(path: "invalid/path")
        
        // When
        sut.fetch(MovieResponse.self, endpoint: invalidEndpoint)
            .sink { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error, NetworkError.invalidURL, "Should return invalid URL error")
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Should not receive value")
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_fetch_whenResponseIsInvalid_shouldReturnError() {
        // Given
        let expectation = expectation(description: "Invalid response")
        let endpoint = Endpoint.searchMovies(query: "test", page: 1)
        
        // When
        sut.fetch(InvalidResponse.self, endpoint: endpoint)
            .sink { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error, NetworkError.decodingError, "Should return decoding error")
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Should not receive value")
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Helper Types
private struct InvalidResponse: Decodable {
    let invalid: Int
} 