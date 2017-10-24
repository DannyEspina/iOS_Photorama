//
//  TagDataSource.swift
//  Photorama
//
//  Created by Danny Espina on 10/23/17.
//  Copyright © 2017 Danny Espina. All rights reserved.
//

import UIKit
import CoreData

class TagDataSource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell" , for: indexPath)
        
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        
        return cell
    }
    
    
    var tags: [Tag] = []
    
    
}
