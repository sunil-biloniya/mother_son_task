//
//  MovieMapper.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation

struct MovieMapper {
    static func map(_ dto: MovieDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            posterPath: dto.posterPath,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            popularity: dto.popularity
        )
    }
} 
