//
//  MovieDetailHeader.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MovieDetailHeader: View {
    let title: String
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack {
            TitleText(text: title)
            
            Spacer()
            
            FavoriteButton(isFavorite: isFavorite, onToggle: {
                onFavoriteToggle()
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            })
        }
    }
} 
