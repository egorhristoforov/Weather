//
//  Country.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import Foundation

struct Country {
    let id: Int
    let name: String
    
    init (from object: CountryObject) {
        id = object.id
        name = object.name
    }
}
