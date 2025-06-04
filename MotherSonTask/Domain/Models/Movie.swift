//
//  MovieResponse.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation
import SwiftData

@Model
final class Movie: Equatable {
    var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var releaseDate: String
    var voteAverage: Double
    var isFavorite: Bool
    var voteCount: Int
    var popularity: Double
    
    init(id: Int, title: String, overview: String, posterPath: String?, releaseDate: String, voteAverage: Double, isFavorite: Bool = false, voteCount: Int, popularity: Double) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.isFavorite = isFavorite
        self.voteCount = voteCount
        self.popularity = popularity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Network Response Models
struct MovieResponse: Codable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieDTO: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
    }
    
    func toMovie() -> Movie {
        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity
        )
    }
} 
