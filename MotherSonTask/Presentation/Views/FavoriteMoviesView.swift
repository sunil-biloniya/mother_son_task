import SwiftUI

struct FavoriteMoviesView: View {
    @State private var viewModel: MovieListViewModel
    @State private var favorites: [Movie] = []
    
    init(repository: MovieRepositoryProtocol) {
        _viewModel = State(initialValue: MovieListViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if favorites.isEmpty {
                    EmptyStateView(
                        message: Constants.Labels.noFavorites,
                        systemImage: "heart.slash"
                    )
                } else {
                    FavoriteMoviesList(
                        favorites: favorites,
                        onFavoriteToggle: { movie in
                            viewModel.toggleFavorite(movie)
                            favorites = viewModel.favorites
                        },
                        viewModel: viewModel
                    )
                }
            }
            .navigationTitle(Constants.Navigation.favoritesTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadFavorites()
                favorites = viewModel.favorites
            }
        }
    }
}

// MARK: - Favorite Movies List
private struct FavoriteMoviesList: View {
    let favorites: [Movie]
    let onFavoriteToggle: (Movie) -> Void
    let viewModel: MovieListViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Constants.UI.defaultSpacing) {
                ForEach(favorites) { movie in
                    FavoriteMovieCard(
                        movie: movie,
                        isFavorite: true,
                        onFavoriteToggle: onFavoriteToggle,
                        viewModel: viewModel
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Favorite Movie Card
private struct FavoriteMovieCard: View {
    let movie: Movie
    let isFavorite: Bool
    let onFavoriteToggle: (Movie) -> Void
    let viewModel: MovieListViewModel
    
    var body: some View {
        NavigationLink(destination: MovieDetailView(
            movie: movie,
            isFavorite: .init(
                get: { viewModel.favorites.contains(where: { $0.id == movie.id }) },
                set: { _ in onFavoriteToggle(movie) }
            ),
            onFavoriteToggle: { onFavoriteToggle(movie) }
        )) {
            VStack(alignment: .leading, spacing: Constants.UI.defaultSpacing) {
                MoviePoster(posterPath: movie.posterPath)
                MovieInfo(
                    title: movie.title,
                    overview: movie.overview,
                    releaseDate: movie.releaseDate,
                    voteAverage: movie.voteAverage,
                    isFavorite: true,
                    onFavoriteToggle: { }
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(Constants.UI.defaultCornerRadius)
            .shadow(radius: Constants.UI.defaultShadowRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
