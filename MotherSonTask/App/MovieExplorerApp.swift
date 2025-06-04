//
//  MovieExplorerApp.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//
import SwiftUI
import SwiftData

@main
struct MovieExplorerApp: App {
    let modelContainer: ModelContainer
    let networkService: NetworkService
    let movieRepository: MovieRepository
    
    init() {
        // Initialize SwiftData container
        do {
            let schema = Schema([Movie.self, FavoriteMovie.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
        // Initialize network service with API key
        networkService = NetworkService(apiKey: Constants.API.apiKey)
        
        // Initialize repository
        movieRepository = MovieRepository(
            networkService: networkService,
            modelContext: modelContainer.mainContext
        )
    }
    
    var body: some Scene {
        WindowGroup {
            MovieListView(repository: movieRepository)
        }
        .modelContainer(modelContainer)
    }
} 
