//
//  ProvinceViewModel.swift
//  Weather
//
//  Created by Nirwan Ramdani on 06/12/24.
//

import Foundation

class ProvinceViewModel {
    var provinces: [Province] = []
    var regencies: [Regency] = []
    
    var selectedProvince: Province?
    var selectedRegency: Regency?
    
    var didUpdateProvinces: (() -> Void)?
    var didUpdateRegencies: (() -> Void)?
    var didFailToLoadData: ((String) -> Void)?
    
    enum ViewState {
        case idle
        case loading
        case success
        case error(String)
    }

    var viewState: ViewState = .idle {
        didSet {
            self.didUpdateViewState?(viewState)
        }
    }

    var didUpdateViewState: ((ViewState) -> Void)?
    
    func fetchProvinces() {
        viewState = .loading
        let urlString = "https://emsifa.github.io/api-wilayah-indonesia/api/provinces.json"
        
        guard let url = URL(string: urlString) else {
            didFailToLoadData?("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.didFailToLoadData?("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.didFailToLoadData?("No data received")
                return
            }
            
            do {
                self.provinces = try JSONDecoder().decode([Province].self, from: data)
                DispatchQueue.main.async {
                    self.didUpdateProvinces?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.didFailToLoadData?("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
        viewState = .success
    }
    
    func fetchRegencies(for provinceId: String) {
        viewState = .loading
        let urlString = "https://emsifa.github.io/api-wilayah-indonesia/api/regencies/\(provinceId).json"
        
        guard let url = URL(string: urlString) else {
            didFailToLoadData?("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.didFailToLoadData?("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.didFailToLoadData?("No data received")
                return
            }
            
            do {
                self.regencies = try JSONDecoder().decode([Regency].self, from: data)
                DispatchQueue.main.async {
                    self.didUpdateRegencies?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.didFailToLoadData?("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
        viewState = .success
    }
    
    func selectProvince(at index: Int) {
        selectedProvince = provinces[index]
        fetchRegencies(for: selectedProvince?.id ?? "")
    }

    func selectRegency(at index: Int) {
        selectedRegency = regencies[index]
    }
    
    func validateInputs(name: String?) -> Bool {
        guard let name = name, !name.isEmpty, selectedProvince != nil, selectedRegency != nil else {
            return false
        }
        return true
    }
}
