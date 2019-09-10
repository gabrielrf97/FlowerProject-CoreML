//
//  Flower.swift
//  FlowerApp
//
//  Created by Gabriel on 09/09/19.
//  Copyright © 2019 gabrielrodrigues. All rights reserved.
//

import Foundation

class Flower {
    var name: String?
    var description: String?
    var latinName: String?
    var pictureUrl: String?
    
    init(name: String, description: String, latinName: String, pictureUrl: String) {
        self.name = name
        self.description = description
        self.latinName = latinName
        self.pictureUrl = pictureUrl
    }
}
