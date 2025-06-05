//
//  Constants.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation

enum Constants {
    // MARK: - API
    enum API {
        static let baseURL = "https://api.themoviedb.org/3"
        static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
        static let apiKey = "9eecc30ae89f253bce3cec4140734493"
    }
    
    // MARK: - UI
    enum UI {
        static let defaultCornerRadius: CGFloat = 12
        static let defaultShadowRadius: CGFloat = 4
        static let defaultPadding: CGFloat = 16
        static let defaultSpacing: CGFloat = 8
        
        enum MovieCard {
            static let posterHeight: CGFloat = 200
            static let overviewLineLimit = 2
        }
        
        enum MovieDetail {
            static let posterHeight: CGFloat = 250
        }
    }
    
    // MARK: - Search
    enum Search {
        static let debounceTime: TimeInterval = 0.5
    }
    
    // MARK: - Image Cache
    enum ImageCache {
        static let maxImages = 100
        static let maxMemoryLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Navigation
    enum Navigation {
        static let moviesTitle = "Movies"
        static let searchPlaceholder = "Search movies..."
        static let favoritesTitle = "Favorites"
    }
    
    // MARK: - Labels
    enum Labels {
        static let overview = "Overview"
        static let additionalInfo = "Additional Information"
        static let popularity = "Popularity:"
        static let voteCount = "Vote Count:"
        static let release = "Release:"
        static let rating = "Rating:"
        static let noMoreMovies = "No more movies to load"
        static let noMoviesFound = "No movies found"
        static let searchEmpty = "Try searching for a movie"
        static let noFavorites = "No favorite movies yet"
    }
} 
