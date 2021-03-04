//
//  ApiError.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import Foundation

enum ApiError: String, Error {
    case unauthorized = "Unauthorized token"
    case unknownError = "Unknown error"
    case notFound = "Resource not found"
    case unableToConvertData = "Cannot convert data"
}
