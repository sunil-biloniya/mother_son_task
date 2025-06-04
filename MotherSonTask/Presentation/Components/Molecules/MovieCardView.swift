//
//  MovieCardView.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading) {
            MoviePosterImage(posterPath: movie.posterPath)
            
            TitleText(text: movie.title)
            CaptionText(text: movie.releaseDate)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
} 
