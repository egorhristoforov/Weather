//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}
