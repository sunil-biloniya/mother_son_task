import XCTest
@testable import MotherSonTask

final class ImageCacheTests: XCTestCase {
    // MARK: - Properties
    var sut: ImageCache!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = ImageCache.shared
        sut.clearCache()
    }
    
    override func tearDown() {
        sut.clearCache()
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_setImage_shouldStoreImageInCache() {
        // Given
        let key = "test_image"
        let image = UIImage(systemName: "star.fill")!
        
        // When
        sut.setImage(image, forKey: key)
        
        // Then
        let cachedImage = sut.getImage(forKey: key)
        XCTAssertNotNil(cachedImage, "Image should be stored in cache")
        XCTAssertEqual(cachedImage, image, "Cached image should match original image")
    }
    
    func test_getImage_whenImageNotInCache_shouldReturnNil() {
        // Given
        let key = "non_existent_image"
        
        // When
        let cachedImage = sut.getImage(forKey: key)
        
        // Then
        XCTAssertNil(cachedImage, "Should return nil for non-existent image")
    }
    
    func test_removeImage_shouldRemoveImageFromCache() {
        // Given
        let key = "test_image"
        let image = UIImage(systemName: "star.fill")!
        sut.setImage(image, forKey: key)
        
        // When
        sut.removeImage(forKey: key)
        
        // Then
        let cachedImage = sut.getImage(forKey: key)
        XCTAssertNil(cachedImage, "Image should be removed from cache")
    }
    
    func test_clearCache_shouldRemoveAllImages() {
        // Given
        let image1 = UIImage(systemName: "star.fill")!
        let image2 = UIImage(systemName: "heart.fill")!
        sut.setImage(image1, forKey: "image1")
        sut.setImage(image2, forKey: "image2")
        
        // When
        sut.clearCache()
        
        // Then
        XCTAssertNil(sut.getImage(forKey: "image1"), "First image should be removed")
        XCTAssertNil(sut.getImage(forKey: "image2"), "Second image should be removed")
    }
    
    func test_concurrentAccess_shouldBeThreadSafe() {
        // Given
        let expectation = expectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100
        
        // When
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let key = "image_\(index)"
            let image = UIImage(systemName: "star.fill")!
            
            sut.setImage(image, forKey: key)
            let cachedImage = sut.getImage(forKey: key)
            
            XCTAssertNotNil(cachedImage, "Image should be accessible concurrently")
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
} 