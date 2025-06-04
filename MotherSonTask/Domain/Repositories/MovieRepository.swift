//
//  MovieRepository.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation
import Combine
import SwiftData

protocol MovieRepositoryProtocol {
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], Error>
    func getFavorites() -> [Movie]
    func toggleFavorite(movie: Movie)
}

class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkService
    private let modelContext: ModelContext
    
    init(networkService: NetworkService, modelContext: ModelContext) {
        self.networkService = networkService
        self.modelContext = modelContext
    }
    
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        let endpoint = Endpoint.popularMovies(page: page)
        return networkService.fetch(MovieResponse.self, endpoint: endpoint)
            .map { response in
                response.results.map { $0.toMovie() }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], Error> {
        let endpoint = Endpoint.searchMovies(query: query, page: page)
        return networkService.fetch(MovieResponse.self, endpoint: endpoint)
            .map { response in
                response.results.map { $0.toMovie() }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func getFavorites() -> [Movie] {
        let descriptor = FetchDescriptor<FavoriteMovie>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        do {
            let favorites = try modelContext.fetch(descriptor)
            return favorites.map { $0.toMovie() }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    func toggleFavorite(movie: Movie) {
        let movieId = movie.id
        let predicate = #Predicate<FavoriteMovie> { favorite in
            favorite.id == movieId
        }
        
        let descriptor = FetchDescriptor<FavoriteMovie>(predicate: predicate)
        
        do {
            let existingFavorites = try modelContext.fetch(descriptor)
            
            if let existingFavorite = existingFavorites.first {
                // Remove from favorites
                modelContext.delete(existingFavorite)
            } else {
                // Add to favorites
                let favoriteMovie = FavoriteMovie(from: movie)
                modelContext.insert(favoriteMovie)
            }
            
            try modelContext.save()
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
} 
