//
//  MovieDetailInfo.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MovieDetailInfo: View {
    let releaseDate: String
    let voteAverage: Double
    
    var body: some View {
        HStack {
            Label(releaseDate, systemImage: "calendar")
            Spacer()
            Label(String(format: "%.1f", voteAverage), systemImage: "star.fill")
        }
        .foregroundColor(.secondary)
    }
} 
