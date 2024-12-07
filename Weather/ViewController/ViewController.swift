//
//  ViewController.swift
//  Weather
//
//  Created by Nirwan Ramdani on 06/12/24.
//

import UIKit
import iOSDropDown

class ViewController: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var provinceSearchTextField: DropDown!
    @IBOutlet weak var regencySearchTextField: DropDown!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var reportButton: UIButton!
    
    
    var provinceViewModel: ProvinceViewModel!
    private var selectedProvinceName: String?
    private var selectedRegencyName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provinceViewModel = ProvinceViewModel()
        bindViewModel()
        provinceViewModel.fetchProvinces()
        
        setupUI()
    }
    
    private func setupUI() {
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
        
    private func bindViewModel() {
        provinceViewModel.didUpdateProvinces = { [weak self] in
            self?.updateProvinceDropdown()
        }
        
        provinceViewModel.didUpdateRegencies = { [weak self] in
            self?.updateRegencyDropdown()
        }
        
        provinceViewModel.didFailToLoadData = { [weak self] errorMessage in
            self?.showError(message: errorMessage)
        }
    }
    
    private func updateProvinceDropdown() {
        provinceSearchTextField.optionArray = provinceViewModel.provinces.map { $0.name }
        provinceSearchTextField.didSelect { [weak self] selectedItem, index, id in
            let selectedProvince = self?.provinceViewModel.provinces[index]
            if let provinceId = selectedProvince?.id {
                self?.selectedProvinceName = selectedProvince?.name
                self?.provinceViewModel.fetchRegencies(for: provinceId)
                
                // Enable regency dropdown
                self?.regencySearchTextField.isUserInteractionEnabled = true
                
                // Reset regency field and fetch regencies
                self!.regencySearchTextField.text = ""
                self!.regencySearchTextField.selectedIndex = -1
                self!.regencySearchTextField.optionArray = []
                self?.selectedRegencyName = nil
                self!.provinceViewModel.fetchRegencies(for: provinceId)
            }
        }
    }
    
    private func updateRegencyDropdown() {
        regencySearchTextField.optionArray = provinceViewModel.regencies.map { $0.name }
        regencySearchTextField.didSelect { [weak self] selectedItem, index, id in
            let selectedRegency = self?.provinceViewModel.regencies[index]
            self?.selectedRegencyName = selectedRegency?.name
        }
    }
    
    @objc private func reportButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            highlightInvalidField(nameTextField)
            return
        }
        
        guard let provinceName = selectedProvinceName else {
            highlightInvalidField(provinceSearchTextField)
            return
        }
        
        guard let regencyName = selectedRegencyName else {
            highlightInvalidField(regencySearchTextField)
            return
        }
        
        // All inputs valid - proceed
        navigateToNextPage(name: name, provinceName: provinceName, regencyName: regencyName)
    }
    
    private func highlightInvalidField(_ field: UIView) {
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.red.cgColor
        field.layer.cornerRadius = 5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            field.layer.borderWidth = 0
        }
    }
    
    private func navigateToNextPage(name: String, provinceName: String, regencyName: String) {
        // Pass the 'name' as the sender to prepare(for:sender:)
        performSegue(withIdentifier: "showWeatherDetail", sender: name)
    }
    
    private func showError(message: String) {
        print(message)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeatherDetail" {
            if let destinationVC = segue.destination as? WeatherDetailViewController {
                // Pass data to WeatherDetailViewController
                destinationVC.name = sender as? String
                destinationVC.provinceName = selectedProvinceName
                destinationVC.regencyName = selectedRegencyName
            }
        }
    }


}

