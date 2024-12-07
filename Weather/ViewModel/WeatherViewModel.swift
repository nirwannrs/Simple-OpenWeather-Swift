//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Nirwan Ramdani on 07/12/24.
//

import Foundation

class WeatherViewModel {
    var weather: Weather?
    var forecast: [Forecast] = [] 
    var greetingMessage: String = ""
    
    var didUpdateWeather: (() -> Void)?
    var didFailToLoadWeather: ((String) -> Void)?
    
    private let apiKey = "ae05713af303fe37003922e0759b7cea"
    
    func fetchWeather(for regencyName: String, provinceName: String? = nil) {
            // Remove "Kabupaten" and "Kota" from the regency name (case insensitive)
            let cleanedRegencyName = cleanRegencyName(regencyName)
            
            // Ensure the regency name is encoded correctly for URL
            let encodedRegency = cleanedRegencyName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedRegency)&units=metric&appid=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                didFailToLoadWeather?("Invalid URL.")
                return
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    self?.didFailToLoadWeather?(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self?.didFailToLoadWeather?("No data received.")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                    let greetingTime = self?.getGreetingTime(from: decodedData)
                    
                    self?.weather = Weather(
                                        greetingTime: greetingTime ?? "Hello",
                                        temperature: decodedData.main.temp,
                                        description: decodedData.weather.first?.description ?? "No description",
                                        cityName: decodedData.name,
                                        weatherMain: decodedData.weather.first?.main ?? "Unknown",
                                        feelsLike: decodedData.main.feels_like,
                                        tempMin: decodedData.main.temp_min,
                                        tempMax: decodedData.main.temp_max,
                                        humidity: decodedData.main.humidity,
                                        pressure: decodedData.main.pressure
                                    )
                    
                    let lat = decodedData.coord.lat
                    let lon = decodedData.coord.lon
                    self?.fetchForecast(lat: lat, lon: lon)
                    
                    self?.greetingMessage = "\(greetingTime ?? "Hello")"
                    self?.didUpdateWeather?()
                } catch {
                    // If regency fetch fails, try province fetch
                    self?.fetchWeatherForFallbackLocation(provinceName ?? "Indonesia")
                }
            }.resume()
        }
        
        private func fetchWeatherForFallbackLocation(_ locationName: String) {
            let cleanedlocationName = cleanProvinceName(locationName)
            
            let encodedLocation = cleanedlocationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedLocation)&units=metric&appid=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                didFailToLoadWeather?("Invalid URL.")
                return
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    self?.didFailToLoadWeather?(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self?.didFailToLoadWeather?("No data received.")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                    let greetingTime = self?.getGreetingTime(from: decodedData)
                    
                    self?.weather = Weather(
                        greetingTime: greetingTime ?? "Hello",
                        temperature: decodedData.main.temp, // Temperature in Celsius
                        description: decodedData.weather.first?.description ?? "No description",
                        cityName: decodedData.name,
                        weatherMain: decodedData.weather.first?.main ?? "Unknown",
                        feelsLike: decodedData.main.feels_like,
                        tempMin: decodedData.main.temp_min,
                        tempMax: decodedData.main.temp_max,
                        humidity: decodedData.main.humidity,
                        pressure: decodedData.main.pressure
                    )
                    
                    let lat = decodedData.coord.lat
                    let lon = decodedData.coord.lon
                    self?.fetchForecast(lat: lat, lon: lon)
                    
                    self?.greetingMessage = "\(greetingTime ?? "Hello")"
                    self?.didUpdateWeather?()
                } catch {
                    // If fallback location fetch fails, try Indonesia as the final fallback
                    self?.fetchWeatherForFallbackLocation("Indonesia")
                }
            }.resume()
        }
    
    private func fetchForecast(lat: Double, lon: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            didFailToLoadWeather?("Invalid URL.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                self?.didFailToLoadWeather?(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                self?.didFailToLoadWeather?("No data received.")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(ForecastResponse.self, from: data)
                
                // Group data by date
                var dailyForecast: [Forecast] = []
                
                var seenDates: Set<String> = Set()
                
                for item in decodedData.list {
                    let date = item.dt_txt.split(separator: " ").first ?? ""
                    
                    // Only take the first data point of each date
                    if !seenDates.contains(String(date)) {
                        seenDates.insert(String(date))
                        let forecast = Forecast(
                            dateTime: String(date),
                            temperature: item.main.temp,
                            description: item.weather.first?.main ?? "No description",
                            icon: item.weather.first?.icon ?? ""
                        )
                        dailyForecast.append(forecast)
                    }
                }
                
                self?.forecast = dailyForecast
                self?.didUpdateWeather?()
            } catch {
                self?.didFailToLoadWeather?("Failed to parse forecast data.")
            }
        }.resume()
    }

    
    private func getGreetingTime(from data: OpenWeatherResponse) -> String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        switch currentHour {
        case 6..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        case 18..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    private func cleanRegencyName(_ name: String) -> String {
        // Remove "Kabupaten" and "Kota" (case insensitive) by replacing them with an empty string
        let cleanName = name.replacingOccurrences(of: "kabupaten ", with: "", options: .caseInsensitive)
                             .replacingOccurrences(of: "kota ", with: "", options: .caseInsensitive)
        return cleanName
    }
    
    private func cleanProvinceName(_ name: String) -> String {
        // Remove "Kabupaten" and "Kota" (case insensitive) by replacing them with an empty string
        let cleanName = name.replacingOccurrences(of: "dki ", with: "", options: .caseInsensitive)
                             .replacingOccurrences(of: "kepulauan ", with: "", options: .caseInsensitive)
        return cleanName
    }
}
