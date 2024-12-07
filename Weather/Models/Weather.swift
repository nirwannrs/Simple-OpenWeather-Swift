//
//  Weather.swift
//  Weather
//
//  Created by Nirwan Ramdani on 07/12/24.
//

import Foundation

// Main weather model
struct Weather {
    let greetingTime: String
    let temperature: Double
    let description: String
    let cityName: String
    let weatherMain: String
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let pressure: Int
}

// Model to decode the response from the API
struct OpenWeatherResponse: Codable {
    let coord: Coordinate
    let name: String
    let weather: [WeatherCondition]
    let main: Main
    let sys: Sys
}

struct Coordinate: Codable {
    let lat: Double
    let lon: Double
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct WeatherCondition: Codable {
    let main: String
    let description: String
}

struct Sys: Codable {
    let country: String
}
