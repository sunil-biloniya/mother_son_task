//
//  MovieDetailView.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Binding var isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
                // Movie Poster
                if let posterPath = movie.posterPath {
                    CachedAsyncImage(url: URL(string: "\(Constants.API.imageBaseURL)\(posterPath)"))
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.UI.MovieDetail.posterHeight)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
                    // Header with Title and Favorite Button
                    MovieDetailHeader(
                        title: movie.title,
                        isFavorite: isFavorite,
                        onFavoriteToggle: onFavoriteToggle
                    )
                    
                    // Release Date and Rating
                    MovieDetailInfo(
                        releaseDate: movie.releaseDate,
                        voteAverage: movie.voteAverage
                    )
                    
                    Divider()
                    
                    // Overview
                    MovieDetailOverview(overview: movie.overview)
                    
                    // Additional Info
                    MovieDetailAdditionalInfo(
                        popularity: movie.popularity,
                        voteCount: movie.voteCount
                    )
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 
