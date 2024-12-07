//
//  Forecast.swift
//  Weather
//
//  Created by Nirwan Ramdani on 07/12/24.
//

import Foundation

struct Forecast {
    let dateTime: String
    let temperature: Double
    let description: String
    let icon: String
}

struct ForecastResponse: Codable {
    let list: [ForecastData]   // List of forecast data
}

struct ForecastData: Codable {
    let dt: Int    // Time of forecast in Unix timestamp
    let main: ForecastMain  // Main weather data (temperature, humidity, etc.)
    let weather: [ForecastWeatherCondition]  // Weather conditions for the forecast
    let dt_txt: String  // Date and time of the forecast (e.g., "2024-12-07 09:00:00")
}

struct ForecastMain: Codable {
    let temp: Double  // Temperature in Kelvin (needs conversion to Celsius)
    let feels_like: Double  // Feels-like temperature in Kelvin
    let temp_min: Double  // Minimum temperature in Kelvin
    let temp_max: Double  // Maximum temperature in Kelvin
    let humidity: Int  // Humidity
    let pressure: Int  // Atmospheric pressure
}

// Weather condition for each forecast (like description and icon)
struct ForecastWeatherCondition: Codable {
    let main: String
    let description: String   // Weather description (e.g., "clear sky")
    let icon: String   // Icon ID (e.g., "01d", "02d")
}
