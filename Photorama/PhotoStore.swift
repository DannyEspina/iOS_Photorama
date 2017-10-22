//
//  PhotoStore.swift
//  Photorama
//
//  Created by Danny Espina on 10/21/17.
//  Copyright © 2017 Danny Espina. All rights reserved.
//

import UIKit

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}
enum PhotosResult {
    case success([Photo])
    case failure(Error)
}
class PhotoStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchPhotos(index: Int, completion: @escaping (PhotosResult) -> Void) {
        let url: URL
        if index == 0 {
         url = FlickrAPI.interestingPhotosURL
        } else {
            url = FlickrAPI.recentPhotosURL
        }
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let httpStatus = response as? HTTPURLResponse {
                //check for http errors
                print("fetchInterestingPhotos")
                print("statusCode is \(httpStatus.statusCode)")
                print("Header fields are \(httpStatus.allHeaderFields)")
            }
            
            let result = self.processPhotoRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            
        }
        task.resume()
    }
//    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
//        let url = FlickrAPI.recentPhotosURL
//        let request = URLRequest(url: url)
//        let task = session.dataTask(with: request) {
//            (data, response, error) -> Void in
//
//            if let httpStatus = response as? HTTPURLResponse {
//                //check for http errors
//                print("fetchRecentPhotos")
//                print("statusCode is \(httpStatus.statusCode)")
//                print("Header fields are \(httpStatus.allHeaderFields)")
//            }
//
//            let result = self.processPhotoRequest(data: data, error: error)
//            OperationQueue.main.addOperation {
//                completion(result)
//            }
//
//        }
//        task.resume()
//    }
    private func processPhotoRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let httpStatus = response as? HTTPURLResponse {
                //check for http errors
                print("fetchImage:")
                print("statusCode is \(httpStatus.statusCode)")
                print("Header fields are \(httpStatus.allHeaderFields)")
            }
            let result = self.processImageRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
}
