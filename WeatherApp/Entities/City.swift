//
//  City.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import Foundation

struct City: Equatable {
    let id: Int
    let name: String
    
    init(from object: CityObject) {
        id = object.id
        name = object.name
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    static func ==(lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id
    }
}
