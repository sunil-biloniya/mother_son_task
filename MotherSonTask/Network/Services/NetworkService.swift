//
//  NetworkService.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation
import Combine

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case noData
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError),
             (.noData, .noData):
            return true
        case (.serverError(let lhsMessage), .serverError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ type: T.Type, endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = Constants.API.baseURL
    private let apiKey: String
    private let session: URLSession
    
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    func fetch<T: Decodable>(_ type: T.Type, endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.url(baseURL: baseURL, apiKey: apiKey) else {
            print("❌ Invalid URL for endpoint: \(endpoint)")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        print("🌐 Request URL: \(url.absoluteString)")
        
        return session.dataTaskPublisher(for: url)
            .mapError { NetworkError.serverError($0.localizedDescription) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.serverError("Status code: \(httpResponse.statusCode)")).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { _ in NetworkError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
} 
