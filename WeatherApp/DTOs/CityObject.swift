//
//  CityObject.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import ObjectMapper

struct CityObject: Mappable {
    var id: Int!
    var name: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["ruName"]
    }
}
