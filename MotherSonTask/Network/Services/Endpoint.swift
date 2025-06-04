//
//  Endpoint.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation

enum Endpoint {
    case searchMovies(query: String, page: Int)
    case movieDetails(id: Int)
    case moviePoster(path: String)
    case popularMovies(page: Int)
    
    var path: String {
        switch self {
        case .searchMovies:
            return "/search/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .moviePoster(let path):
            return "https://image.tmdb.org/t/p/w500\(path)"
        case .popularMovies:
            return "/movie/popular"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .movieDetails:
            return []
        case .moviePoster:
            return []
        case .popularMovies(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        }
    }
    
    func url(baseURL: String, apiKey: String) -> URL? {
        var components = URLComponents(string: baseURL + path)
        
        var queryItems = self.queryItems
        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        components?.queryItems = queryItems
        
        return components?.url
    }
} 
