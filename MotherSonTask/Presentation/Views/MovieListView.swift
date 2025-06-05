//
//  FavoriteButton.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI

// MARK: - Main View
struct MovieListView: View {
    @State private var viewModel: MovieListViewModel
    @State private var searchText = ""
    
    init(repository: MovieRepositoryProtocol) {
        _viewModel = State(initialValue: MovieListViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, onTextChange: handleSearchTextChange)
                MovieListContent(
                    viewModel: viewModel,
                    onAppear: { viewModel.loadInitialData() }
                )
            }
            .navigationTitle(Constants.Navigation.moviesTitle)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        viewModel.searchQuery = newValue
        if newValue.isEmpty {
            viewModel.resetSearch()
        } else {
            viewModel.searchMovies()
        }
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    let onTextChange: (String) -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 18, weight: .medium))
                
                TextField(Constants.Navigation.searchPlaceholder, text: $text)
                    .onChange(of: text) { _, newValue in
                        onTextChange(newValue)
                    }
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

// MARK: - Favorite Button
struct FavoriteButton: View {
    let isFavorite: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? .red : .gray)
                .imageScale(.large)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

// MARK: - Movie List Content
struct MovieListContent: View {
    let viewModel: MovieListViewModel
    let onAppear: () -> Void
    
    var body: some View {
        ZStack {
            if viewModel.movies.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    message: viewModel.searchQuery.isEmpty ? Constants.Labels.noMoviesFound : Constants.Labels.searchEmpty,
                    systemImage: viewModel.searchQuery.isEmpty ? "film" : "magnifyingglass"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: Constants.UI.defaultSpacing) {
                        ForEach(viewModel.movies) { movie in
                            MovieCardNavigationLink(
                                movie: movie,
                                isFavorite: viewModel.favorites.contains(where: { $0.id == movie.id }),
                                onFavoriteToggle: { viewModel.toggleFavorite(movie) }
                            )
                            .onAppear {
                                if movie == viewModel.movies.last && !viewModel.isLoadingMore {
                                    viewModel.loadMoreMovies()
                                }
                            }
                        }
                        
                        LoadingIndicators(
                            isLoading: viewModel.isLoading,
                            isLoadingMore: viewModel.isLoadingMore,
                            hasMorePages: viewModel.hasMorePages,
                            movies: viewModel.movies
                        )
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: onAppear)
    }
}

// MARK: - Movie Card Navigation Link
struct MovieCardNavigationLink: View {
    let movie: Movie
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        NavigationLink(destination: MovieDetailView(
            movie: movie,
            isFavorite: .init(
                get: { isFavorite },
                set: { _ in onFavoriteToggle() }
            ),
            onFavoriteToggle: onFavoriteToggle
        )) {
            MovieCard(movie: movie, isFavorite: isFavorite, onFavoriteToggle: onFavoriteToggle)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Loading Indicators
struct LoadingIndicators: View {
    let isLoading: Bool
    let isLoadingMore: Bool
    let hasMorePages: Bool
    let movies: [Movie]
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            
            if !hasMorePages && !movies.isEmpty {
                Text("No more movies to load")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

// MARK: - Movie Card
struct MovieCard: View {
    let movie: Movie
    let isFavorite: Bool
    let onFavoriteToggle: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
            MoviePoster(posterPath: movie.posterPath)
            MovieInfo(
                title: movie.title,
                overview: movie.overview,
                releaseDate: movie.releaseDate,
                voteAverage: movie.voteAverage,
                isFavorite: isFavorite,
                onFavoriteToggle: onFavoriteToggle
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Constants.UI.defaultCornerRadius)
        .shadow(radius: Constants.UI.defaultShadowRadius)
    }
}

// MARK: - Movie Poster
struct MoviePoster: View {
    let posterPath: String?
    
    var body: some View {
        if let posterPath = posterPath {
            CachedAsyncImage(url: URL(string: "\(Constants.API.imageBaseURL)\(posterPath)"))
                .aspectRatio(contentMode: .fill)
                .frame(height: Constants.UI.MovieCard.posterHeight)
                .clipped()
                .cornerRadius(Constants.UI.defaultCornerRadius)
        }
    }
}

// MARK: - Movie Info
struct MovieInfo: View {
    let title: String
    let overview: String
    let releaseDate: String
    let voteAverage: Double
    let isFavorite: Bool
    let onFavoriteToggle: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                if let onFavoriteToggle = onFavoriteToggle {
                    FavoriteButton(isFavorite: isFavorite, onToggle: onFavoriteToggle)
                        .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            Text(overview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(Constants.UI.MovieCard.overviewLineLimit)
            
            HStack {
                Text("\(Constants.Labels.release) \(releaseDate)")
                    .font(.caption)
                
                Spacer()
                
                Text("\(Constants.Labels.rating) \(String(format: "%.1f", voteAverage))")
                    .font(.caption)
            }
        }
    }
} 
