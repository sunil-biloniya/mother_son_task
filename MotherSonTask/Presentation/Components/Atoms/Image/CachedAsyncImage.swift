//
//  CachedAsyncImage.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    let height: CGFloat
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(url: URL?, height: CGFloat = 200) {
        self.url = url
        self.height = height
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
        }
        .frame(height: height)
        .clipped()
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        // If not in cache, download
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isLoading = false }
            
            guard let data = data,
                  let downloadedImage = UIImage(data: data) else {
                return
            }
            
            // Cache the downloaded image
            ImageCache.shared.setImage(downloadedImage, forKey: url.absoluteString)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
} 
