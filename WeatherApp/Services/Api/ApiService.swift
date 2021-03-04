//
//  ApiService.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

protocol ApiServiceProtocol {
    func getCountriesList() -> Observable<[CountryObject]>
    func getCitiesListForCountry(with id: Int) -> Observable<[CityObject]>
    
    func getWeatherHistoryFor(city: String) -> Observable<WeatherListObject>
    func getWeatherHistoryByGeolocation(longitude: Double, latitude: Double) -> Observable<WeatherListObject>
    
    func getCurrentWeatherFor(city: String) -> Observable<CurrentWeatherObject>
    func getCurrentWeatherByGeolocation(longitude: Double, latitude: Double) -> Observable<CurrentWeatherObject>
}

class ApiService: BaseApiService, ApiServiceProtocol {
    func getCountriesList() -> Observable<[CountryObject]> {
        let request = ApiRequest(path: citiesURL + "countries")
        return callAPIRequest(request: request)
    }
    
    func getCitiesListForCountry(with id: Int) -> Observable<[CityObject]> {
        let request = ApiRequest(path: citiesURL + "countries/\(id)/cities")
        return callAPIRequest(request: request)
    }
    
    func getWeatherHistoryFor(city: String) -> Observable<WeatherListObject> {
        let request = ApiRequest(path: weatherURL + "forecast",
                                 parameters: ["q": city, "appid": apiKey,
                                              "units": "metric", "lang": "ru"],
                                 encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }
    
    func getWeatherHistoryByGeolocation(longitude: Double, latitude: Double) -> Observable<WeatherListObject> {
        let request = ApiRequest(path: weatherURL + "forecast",
                                 parameters: ["lat": latitude, "lon": longitude,
                                              "appid": apiKey, "units": "metric",
                                              "lang": "ru"],
                                 encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }
    
    func getCurrentWeatherFor(city: String) -> Observable<CurrentWeatherObject> {
        let request = ApiRequest(path: weatherURL + "weather",
                                 parameters: ["q": city, "appid": apiKey,
                                              "units": "metric", "lang": "ru"],
                                 encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }
    
    func getCurrentWeatherByGeolocation(longitude: Double, latitude: Double) -> Observable<CurrentWeatherObject> {
        let request = ApiRequest(path: weatherURL + "weather",
                                 parameters: ["lat": latitude, "lon": longitude,
                                              "appid": apiKey, "units": "metric",
                                              "lang": "ru"],
                                 encoding: URLEncoding.default)
        return callAPIRequest(request: request)
    }
}

class BaseApiService {
    fileprivate let citiesURL = "http://178.250.158.11/api/v1/"
    fileprivate let weatherURL = "https://api.openweathermap.org/data/2.5/"
    
    fileprivate let apiKey = "Openweathermap API KEY"

    fileprivate func callAPIRequest<T: BaseMappable>(request: ApiRequest) -> Observable<[T]> {
        RxAlamofire.requestJSON(request.method,
                                request.path,
                                parameters: request.parameters,
                                encoding: request.encoding,
                                headers: request.headers)
            .flatMap { (_, json) -> Observable<[T]> in
                guard let model = Mapper<T>().mapArray(JSONObject: json) else { throw ApiError.unableToConvertData }
                return .just(model)
            }
    }
    
    fileprivate func callAPIRequest<T: BaseMappable>(request: ApiRequest) -> Observable<T> {
        RxAlamofire.requestJSON(request.method,
                                request.path,
                                parameters: request.parameters,
                                encoding: request.encoding,
                                headers: request.headers)
            .flatMap { (_, json) -> Observable<T> in
                guard let json = json as? [String: Any] else { throw ApiError.unableToConvertData }
                guard let model = Mapper<T>().map(JSON: json) else { throw ApiError.unableToConvertData }
                
                return .just(model)
            }
    }
}
