//
//  FavoriteMovie.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation
import SwiftData

@Model
final class FavoriteMovie {
    var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var releaseDate: String
    var voteAverage: Double
    var dateAdded: Date
    var voteCount: Int
    var popularity: Double
    
    init(id: Int, title: String, overview: String, posterPath: String?, releaseDate: String, voteAverage: Double, voteCount: Int, popularity: Double) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.dateAdded = Date()
        self.voteCount = voteCount
        self.popularity = popularity
    }
    
    convenience init(from movie: Movie) {
        self.init(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            popularity: movie.popularity
        )
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
