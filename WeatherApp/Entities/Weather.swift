//
//  Weather.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import Foundation

struct CurrentWeather {
    let coordinates: CityCoordinates?
    let weatherDescription: [WeatherDescription]
    let weatherInfo: WeatherInfo?
    
    init(from object: CurrentWeatherObject) {
        if let coordinates = object.coordinates {
            self.coordinates = CityCoordinates(from: coordinates)
        } else {
            coordinates = nil
        }
        
        if let info = object.weatherInfo {
            weatherInfo = WeatherInfo(from: info)
        } else {
            weatherInfo = nil
        }
        
        weatherDescription = (object.weatherDescription ?? []).map { WeatherDescription(from: $0) }
    }
}

struct WeatherList {
    let weatherHistory: [WeatherHistory]
    
    init(from object: WeatherListObject) {
        if let history = object.weatherHistory {
            weatherHistory = history.map { WeatherHistory(from: $0) }
        } else {
            weatherHistory = []
        }
    }
}

struct WeatherHistory {
    let date: Date
    let weatherInfo: WeatherInfo
    let weatherDescription: [WeatherDescription]
    
    init(from object: WeatherHistoryObject) {
        date = object.date
        weatherInfo = WeatherInfo(from: object.weatherInfo)
        weatherDescription = object.weatherDescription.map { WeatherDescription(from: $0) }
    }
}

struct WeatherInfo {
    let temp: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double
    
    init(from object: WeatherInfoObject) {
        temp = object.temp
        feelsLike = object.feelsLike
        pressure = object.pressure
        humidity = object.humidity
    }
}

struct WeatherDescription {
    let title: String
    let description: String
    
    init(from object: WeatherDescriptionObject) {
        title = object.title
        description = object.description
    }
}

struct CityCoordinates {
    let latitude: Double
    let longitude: Double
    
    init(from object: CityCoordinatesObject) {
        latitude = object.latitude
        longitude = object.longitude
    }
}
