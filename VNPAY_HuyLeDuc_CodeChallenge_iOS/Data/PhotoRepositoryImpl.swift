//
//  PhotoRepositoryImpl.swift
//  VNPAY_HuyLeDuc_CodeChallenge_iOS
//
//  Created by Đức Huy Lê on 12/6/25.
//

import UIKit
import Foundation

/* Protocol defining photo fetching and image loading methods. */
protocol PhotoRepository {
    // Fetch photos from the API.
    func fetchPhotos(page: Int, limit: Int, completion: @escaping ([Photo]?) -> Void)
    @discardableResult

    // Load an image from the given URL.
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask?
}

/* Implementation of PhotoRepository using URLSession */
class PhotoRepositoryImpl: PhotoRepository {
    private let session: URLSession

    // Cache for downloaded images to improve performance.
    private var imageCache = NSCache<NSString, UIImage>()

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func fetchPhotos(page: Int, limit: Int, completion: @escaping ([Photo]?) -> Void) {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)") else {
            completion(nil)
            return
        }

        session.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let photos = try? JSONDecoder().decode([Photo].self, from: data)
            DispatchQueue.main.async {
                completion(photos)
            }
        }.resume()
    }

    // Asynchronously loads an image from the specified URL.
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            completion(cachedImage)
            return nil
        }

        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return nil
        }

        let task = session.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self.imageCache.setObject(image, forKey: url as NSString)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
        return task
    }
    
}
