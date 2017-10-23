//
//  PhotoDataSource.swift
//  Photorama
//
//  Created by Danny Espina on 10/22/17.
//  Copyright © 2017 Danny Espina. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
     var photos = [Photo]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifer = "PhotoCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifer, for: indexPath)
        
        return cell
    }
    
    
   
}
