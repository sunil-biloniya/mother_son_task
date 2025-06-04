//
//  MovieDetailOverview.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct MovieDetailOverview: View {
    let overview: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
            SubtitleText(text: Constants.Labels.overview)
            BodyText(text: overview)
        }
    }
} 
