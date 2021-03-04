//
//  WeatherObject.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import ObjectMapper

struct CurrentWeatherObject: Mappable {
    var coordinates: CityCoordinatesObject?
    var weatherDescription: [WeatherDescriptionObject]?
    var weatherInfo: WeatherInfoObject?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        coordinates <- map["coord"]
        weatherDescription <- map["weather"]
        weatherInfo <- map["main"]
    }
}

struct WeatherListObject: Mappable {
    var status: String!
    var weatherHistory: [WeatherHistoryObject]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        status <- map["cod"]
        weatherHistory <- map["list"]
    }
}

struct WeatherHistoryObject: Mappable {
    var date: Date!
    var weatherInfo: WeatherInfoObject!
    var weatherDescription: [WeatherDescriptionObject]!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        date <- (map["dt"], DateTransform())
        weatherInfo <- map["main"]
        weatherDescription <- map["weather"]
    }
}

struct WeatherInfoObject: Mappable {
    var temp: Double!
    var feelsLike: Double!
    var pressure: Double!
    var humidity: Double!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        temp <- map["temp"]
        feelsLike <- map["feels_like"]
        pressure <- map["pressure"]
        humidity <- map["humidity"]
    }
}

struct WeatherDescriptionObject: Mappable {
    var title: String!
    var description: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        title <- map["main"]
        description <- map["description"]
    }
}

struct CityCoordinatesObject: Mappable {
    var latitude: Double!
    var longitude: Double!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        latitude <- map["lat"]
        longitude <- map["lon"]
    }
}
