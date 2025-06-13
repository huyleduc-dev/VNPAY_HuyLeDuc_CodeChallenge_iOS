//
//  PhotoRepositoryTests.swift
//  VNPAY_HuyLeDuc_CodeChallenge_iOS_Tests
//
//  Created by Đức Huy Lê on 13/6/25.
//

import XCTest
@testable import VNPAY_HuyLeDuc_CodeChallenge_iOS

// A mock URL protocol to intercept network requests and return stubbed responses.
class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var response: URLResponse?
    static var error: Error?
    
    // Indicates whether to handle the given request. Here we allow all requests.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let response = MockURLProtocol.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = MockURLProtocol.stubResponseData {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}

// Unit tests for the PhotoRepositoryImpl class.
class PhotoRepositoryTests: XCTestCase {
    
    var repository: PhotoRepositoryImpl!
    var session: URLSession!
        
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        repository = PhotoRepositoryImpl(session: session)
    }
    
    override func tearDown() {
        repository = nil
        session = nil
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        super.tearDown()
    }
    
    // Tests that fetchPhotos successfully decodes and returns a valid array of Photo objects.
    func testFetchPhotosSuccess() {
        // Sample JSON for a single Photo object.
        let jsonString = """
        [
            {
                "id": "1",
                "author": "Test Author",
                "width": 100,
                "height": 200,
                "download_url": "https://example.com/1.jpg"
            }
        ]
        """
        
        // Setup stub data and a sample HTTPURLResponse.
        MockURLProtocol.stubResponseData = jsonString.data(using: .utf8)
        let url = URL(string: "https://picsum.photos/v2/list?page=1&limit=100")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response = response
        
        let expectation = self.expectation(description: "FetchPhotos")
        
        repository.fetchPhotos(page: 1, limit: 100) { photos in
            // Assert that the photos array is not nil and contains the expected data.
            XCTAssertNotNil(photos)
            XCTAssertEqual(photos?.count, 1)
            XCTAssertEqual(photos?.first?.author, "Test Author")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Tests that loadImage correctly retrieves and decodes an image.
    func testLoadImageSuccess() {
        // Create a sample red image.
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.red.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        let redImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Ensure that image data can be generated.
        guard let imageData = redImage?.pngData() else {
            XCTFail("Failed to create image data")
            return
        }
        
        // Setup the stub data and response for loadImage.
        MockURLProtocol.stubResponseData = imageData
        let url = URL(string: "https://example.com/1.jpg")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        MockURLProtocol.response = response
        
        let expectation = self.expectation(description: "LoadImage")
        
        // Call loadImage and assert that the image is retrieved successfully.
        _ = repository.loadImage(from: "https://example.com/1.jpg", completion: { image in
            XCTAssertNotNil(image)
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
