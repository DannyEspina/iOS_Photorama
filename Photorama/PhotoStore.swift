//
//  PhotoStore.swift
//  Photorama
//
//  Created by Danny Espina on 10/21/17.
//  Copyright © 2017 Danny Espina. All rights reserved.
//

import UIKit
import CoreData

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
    
    let imageStore = ImageStore()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
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
                print("fetchPhotos")
                print("statusCode is \(httpStatus.statusCode)")
                print("Header fields are \(httpStatus.allHeaderFields)")
            }
            
            var result = self.processPhotoRequest(data: data, error: error)
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
            
        }
        task.resume()
    }
    private func processPhotoRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData, into: persistentContainer.viewContext)
    }
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL.")
        }
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let httpStatus = response as? HTTPURLResponse {
                //check for http errors
                print("fetchImage:")
                print("statusCode is \(httpStatus.statusCode)")
                print("Header fields are \(httpStatus.allHeaderFields)")
            }
            let result = self.processImageRequest(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
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
    func fetchAllPhotos(completion: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        //let sortBydateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        
        //fetchRequest.sortDescriptors = [sortBydateTaken]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    func saveContextIfNeeded() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            print("Save context")
            try? context.save()
        }
    }
}
