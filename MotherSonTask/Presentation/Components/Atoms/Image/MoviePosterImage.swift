//
//  MoviePosterImage.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MoviePosterImage: View {
    let posterPath: String?
    let height: CGFloat
    
    init(posterPath: String?, height: CGFloat = 200) {
        self.posterPath = posterPath
        self.height = height
    }
    
    var body: some View {
        if let posterPath = posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            CachedAsyncImage(url: url, height: height)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: height)
        }
    }
} 
