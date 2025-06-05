//
//  NetworkService.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation
import Combine
import Network

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL(String)
    case invalidResponse(String)
    case decodingError
    case serverError(String)
    case noData
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let message):
            return "Invalid URL: \(message)"
        case .invalidResponse(let message):
            return "Invalid Response: \(message)"
        case .decodingError:
            return "Failed to decode server response"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .noData:
            return "No data received from server"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let lhsMessage), .invalidURL(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.invalidResponse(let lhsMessage), .invalidResponse(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.decodingError, .decodingError),
             (.noInternetConnection, .noInternetConnection),
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
        if !NetworkReachability.isConnectedToNetwork() {
            return Fail(error: NetworkError.noInternetConnection).eraseToAnyPublisher()
        }
        
        guard let url = endpoint.url(baseURL: baseURL, apiKey: apiKey) else {
            let errorMessage = "Invalid URL for endpoint: \(endpoint.path)"
            print("❌ \(errorMessage)")
            return Fail(error: NetworkError.invalidURL(errorMessage)).eraseToAnyPublisher()
        }
        
        print("🌐 Request URL: \(url.absoluteString)")
        
        return session.dataTaskPublisher(for: url)
            .mapError { NetworkError.serverError($0.localizedDescription) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorMessage = "Invalid response type received from server"
                    print("❌ \(errorMessage)")
                    return Fail(error: NetworkError.invalidResponse(errorMessage)).eraseToAnyPublisher()
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
