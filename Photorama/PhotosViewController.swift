//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Danny Espina on 10/21/17.
//  Copyright © 2017 Danny Espina. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(self.photoTypeChanged(_:)), for: .valueChanged)

        store.fetchPhotos(index: segmentControl.selectedSegmentIndex){
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                if let firstPhoto = photos.first {
                    self.updateImageView(for: firstPhoto)
                }
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            }
            
        }
}
    func updateImageView(for photo: Photo) {
        store.fetchImage(for: photo) {
            (imageResult) -> Void in
            
            switch imageResult {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }
    @objc func photoTypeChanged(_ segControl: UISegmentedControl){
        
        store.fetchPhotos(index: segControl.selectedSegmentIndex){
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                if let firstPhoto = photos.first {
                    self.updateImageView(for: firstPhoto)
                }
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            }
            
        }
    }
}
