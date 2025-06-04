//
//  MovieDetailAdditionalInfo.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MovieDetailAdditionalInfo: View {
    let popularity: Double
    let voteCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
            SubtitleText(text: Constants.Labels.additionalInfo)
                .padding(.top)
            
            HStack {
                Text(Constants.Labels.popularity)
                Spacer()
                Text(String(format: "%.1f", popularity))
            }
            
            HStack {
                Text(Constants.Labels.voteCount)
                Spacer()
                Text("\(voteCount)")
            }
        }
        .foregroundColor(.secondary)
    }
} 
