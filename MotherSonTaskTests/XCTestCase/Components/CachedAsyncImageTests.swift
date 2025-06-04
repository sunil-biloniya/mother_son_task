import XCTest
import SwiftUI
@testable import MotherSonTask

final class CachedAsyncImageTests: XCTestCase {
    // MARK: - Properties
    var sut: CachedAsyncImage!
    var imageCache: ImageCache!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        imageCache = ImageCache.shared
        imageCache.clearCache()
    }
    
    override func tearDown() {
        imageCache.clearCache()
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_init_shouldCreateView() {
        // Given
        let url = URL(string: "https://example.com/image.jpg")!
        
        // When
        sut = CachedAsyncImage(url: url)
        
        // Then
        XCTAssertNotNil(sut, "View should be created")
    }
    
    func test_init_whenURLIsNil_shouldCreateView() {
        // When
        sut = CachedAsyncImage(url: nil)
        
        // Then
        XCTAssertNotNil(sut, "View should be created with nil URL")
    }
    
    func test_loadImage_whenImageInCache_shouldUseCachedImage() {
        // Given
        let url = URL(string: "https://example.com/image.jpg")!
        let image = UIImage(systemName: "star.fill")!
        imageCache.setImage(image, forKey: url.absoluteString)
        
        // When
        sut = CachedAsyncImage(url: url)
        
        // Then
        let cachedImage = imageCache.getImage(forKey: url.absoluteString)
        XCTAssertNotNil(cachedImage, "Should use cached image")
        XCTAssertEqual(cachedImage, image, "Cached image should match original image")
    }
    
    func test_loadImage_whenImageNotInCache_shouldDownloadImage() {
        // Given
        let url = URL(string: "https://example.com/image.jpg")!
        
        // When
        sut = CachedAsyncImage(url: url)
        
        // Then
        let expectation = expectation(description: "Download image")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let cachedImage = self.imageCache.getImage(forKey: url.absoluteString)
            XCTAssertNotNil(cachedImage, "Should download and cache image")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_viewDimensions_shouldMatchContentMode() {
        // Given
        let url = URL(string: "https://example.com/image.jpg")!
        
        // When
        sut = CachedAsyncImage(url: url)
            .frame(width: 100, height: 100)
        
        // Then
        let view = sut.body as? Image
        XCTAssertNotNil(view, "View should be an Image")
        XCTAssertEqual(view?.resizable(), true, "Image should be resizable")
    }
} 