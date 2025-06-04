//
//  MovieListViewModel.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import Foundation
import Combine
import SwiftData

@Observable
class MovieListViewModel {
    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchSubject = PassthroughSubject<String, Never>()
    private var hasLoadedInitialData = false
    
    var movies: [Movie] = []
    var favorites: [Movie] = []
    var searchQuery = ""
    var isLoading = false
    var isLoadingMore = false
    var error: Error?
    var currentPage = 1
    var hasMorePages = true
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
        setupSearchDebounce()
        loadFavorites()
    }
    
    func loadInitialData() {
        if !hasLoadedInitialData {
            loadPopularMovies()
        }
    }
    
    private func setupSearchDebounce() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        currentPage = 1
        
        if query.isEmpty {
            loadPopularMovies()
            return
        }
        
        repository.searchMovies(query: query, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.error = error
                    self.hasMorePages = false
                }
            } receiveValue: { [weak self] newMovies in
                guard let self = self else { return }
                self.movies = newMovies
                self.updateFavoriteStates()
                self.hasMorePages = !newMovies.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func loadPopularMovies() {
        guard !isLoading && !isLoadingMore else { return }
        
        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        error = nil
        
        repository.getPopularMovies(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                self.isLoadingMore = false
                if case .failure(let error) = completion {
                    self.error = error
                    self.hasMorePages = false
                }
            } receiveValue: { [weak self] newMovies in
                guard let self = self else { return }
                if self.currentPage == 1 {
                    self.movies = newMovies
                } else {
                    self.movies.append(contentsOf: newMovies)
                }
                self.updateFavoriteStates()
                self.hasMorePages = !newMovies.isEmpty
                self.hasLoadedInitialData = true
            }
            .store(in: &cancellables)
    }
    
    func loadMoreMovies() {
        guard !isLoading && !isLoadingMore && hasMorePages else { return }
        currentPage += 1
        
        if searchQuery.isEmpty {
            loadPopularMovies()
        } else {
            performSearch(query: searchQuery)
        }
    }
    
    func searchMovies() {
        searchSubject.send(searchQuery)
    }
    
    func toggleFavorite(_ movie: Movie) {
        // First update the UI state
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies[index].isFavorite.toggle()
        }
        
        // Then update the repository
        repository.toggleFavorite(movie: movie)
        
        // Finally, reload favorites to ensure consistency
        loadFavorites()
    }
    
    private func updateFavoriteStates() {
        for (index, movie) in movies.enumerated() {
            movies[index].isFavorite = favorites.contains(where: { $0.id == movie.id })
        }
    }
    
    func loadFavorites() {
        favorites = repository.getFavorites()
        updateFavoriteStates()
    }
    
    func resetSearch() {
        searchQuery = ""
        movies = []
        currentPage = 1
        hasMorePages = true
        hasLoadedInitialData = false
        loadPopularMovies()
    }
} 
