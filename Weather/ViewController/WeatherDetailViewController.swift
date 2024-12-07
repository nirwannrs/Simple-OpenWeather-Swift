//
//  WeatherDetailViewController.swift
//  Weather
//
//  Created by Nirwan Ramdani on 07/12/24.
//

import UIKit

class WeatherDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var name: String?
    var provinceName: String?
    var regencyName: String?
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    
    private let weatherViewModel = WeatherViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        loadWeatherData()

        // Do any additional setup after loading the view.
        print("Name: \(name ?? "")")
        print("Province: \(provinceName ?? "")")
        print("Regency: \(regencyName ?? "")")
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
    }
    
    private func bindViewModel() {
            weatherViewModel.didUpdateWeather = { [weak self] in
                DispatchQueue.main.async {
                    self?.updateLabelMessage()
                    self?.forecastTableView.reloadData()
                }
            }
            
            weatherViewModel.didFailToLoadWeather = { [weak self] errorMessage in
                DispatchQueue.main.async {
                    self?.showError(message: errorMessage)
                }
            }
        }
        
        private func loadWeatherData() {
            guard let regencyName = regencyName else { return }
            weatherViewModel.fetchWeather(for: regencyName, provinceName: provinceName)
        }
        
        private func updateLabelMessage() {
            greetingLabel.text = "\(weatherViewModel.greetingMessage), \(name ?? "")"
            if let temperature = weatherViewModel.weather?.temperature {
                        temperatureLabel.text = String(format: "%.1f°C", temperature)
                    }
            if let cityName = weatherViewModel.weather?.cityName {
                cityLabel.text = cityName
                    }
            if let weatherMain = weatherViewModel.weather?.weatherMain {
                descriptionLabel.text = "\(weatherMain)"
                    }
            
        }
        
        private func showError(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherViewModel.forecast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)
                
                let forecastItem = weatherViewModel.forecast[indexPath.row]
                
                // Configure the cell with the forecast data
                cell.textLabel?.text = "\(forecastItem.dateTime) - \(forecastItem.temperature)°C, \(forecastItem.description)"
                
                // Optionally, load the icon image
                if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(forecastItem.icon).png") {
                    let task = URLSession.shared.dataTask(with: iconURL) { data, response, error in
                        if let data = data, error == nil {
                            DispatchQueue.main.async {
                                cell.imageView?.image = UIImage(data: data)
                                cell.setNeedsLayout() // Ensure the layout gets updated
                            }
                        }
                    }
                    task.resume()
                }
                
                return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
