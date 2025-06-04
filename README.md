# Movie Explorer iOS App

A modern iOS application that allows users to explore movies, search for their favorite films, and maintain a personal favorites list.

## Features

- Search movies by title
- View detailed movie information
- Add/remove movies to favorites
- Persistent storage using SwiftData
- Clean Architecture implementation
- MVVM design pattern
- Comprehensive unit testing

## Technical Stack

- Swift 5.9+
- iOS 17.0+
- SwiftUI for UI
- SwiftData for persistence
- Combine for reactive programming
- XCTest for unit testing

## Architecture

The project follows Clean Architecture principles with the following layers:

- **Presentation Layer**: Views and ViewModels (MVVM)
- **Domain Layer**: Use Cases and Domain Models
- **Data Layer**: Repositories and Data Sources
- **Network Layer**: API Services and Network Models

## Setup Instructions

1. Clone the repository
2. Open `MovieExplorer.xcodeproj` in Xcode 15.0 or later
3. Get your API key from [The Movie Database (TMDb)](https://www.themoviedb.org/documentation/api)
4. Add your API key to the `Config.xcconfig` file
5. Build and run the project

## Running Tests

1. Open the project in Xcode
2. Press `Cmd + U` to run all tests
3. Or select specific test targets from the test navigator

## Project Structure

```
MovieExplorer/
├── App/
│   └── MovieExplorerApp.swift
├── Presentation/
│   ├── Views/
│   └── ViewModels/
├── Domain/
│   ├── Models/
│   ├── UseCases/
│   └── Repositories/
├── Data/
│   ├── Repositories/
│   └── DataSources/
├── Network/
│   ├── Services/
│   └── Models/
└── Core/
    ├── Extensions/
    └── Utilities/
```

## Dependencies

- No external dependencies required
- Uses native Swift and iOS frameworks

## License

This project is for demonstration purposes only. 