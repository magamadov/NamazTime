//
//  ViewController.swift
//  namazTime
//
//  Created by ZELIMKHAN MAGAMADOV on 29.02.2020.
//  Copyright © 2020 ZELIMKHAN MAGAMADOV. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var fadjrLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var zukhrLabel: UILabel!
    @IBOutlet weak var asrLabel: UILabel!
    @IBOutlet weak var magribLabel: UILabel!
    @IBOutlet weak var ishaLabel: UILabel!
    
    // MARK: - View Namaz
    @IBOutlet weak var fajrView: UIView!
    @IBOutlet weak var sunriseView: UIView!
    @IBOutlet weak var zukhrView: UIView!
    @IBOutlet weak var asrView: UIView!
    @IBOutlet weak var magribView: UIView!
    @IBOutlet weak var ishaView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDateLabel.text = getCurrentDate()
        setBorderNamaz(type: .sunrise)
        setBorderNamaz(type: .magrib)
        
    }
    
    let location = CLLocationManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        location.delegate = self
        // location.desiredAccuracy = kCLLocationAccuracyBest
        location.requestWhenInUseAuthorization()
        location.startUpdatingLocation()
        
    }
    
    enum NamazType {
        case fajr
        case sunrise
        case zukhr
        case asr
        case magrib
        case isha
        case empty
    }
    
    func setBorderNamaz(type: NamazType) {
        
        var namazView: UIView
        
        switch type {
        case .fajr:
            namazView = fajrView
        case .sunrise:
            namazView = sunriseView
        case .zukhr:
            namazView = zukhrView
        case .asr:
            namazView = asrView
        case .magrib:
            namazView = magribView
        case .isha:
            namazView = ishaView
        }
        namazView.layer.borderColor = UIColor.blue.cgColor
        namazView.layer.borderWidth = 1
        namazView.layer.cornerRadius = 15
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let myLocation = locations.first {
            //location.stopUpdatingLocation()
            print(myLocation.coordinate.latitude, myLocation.coordinate.longitude)
            getUserLocation(long: myLocation.coordinate.longitude.description, lat: myLocation.coordinate.latitude.description)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Ошибка")
    }
    
    func getCurrentDate() -> String {
        
        let currentDate = Date()
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd MMMM YYYY"
        formatter.locale = Locale(identifier: "ru")
        
        return formatter.string(from: currentDate)
    }
    
    func getUserLocation(long: String, lat: String) {
        
        let apiKey = "50650d1ad048ac"
        let url = URL(string: "https://eu1.locationiq.com/v1/reverse.php?key=\(apiKey)&lat=\(lat)&lon=\(long)&format=json&accept-language=en&namedetails=0")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            guard let address = json["address"] as? [String: String] else {
                return
            }
            if let country = address["country"], let city = address["city"] {
                self.getNamazTime(country: country, city: city)
            }
        }
        
        task.resume()
        
    }
    
    func getNamazTime(country: String, city: String) {
        
        let cityOk = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let countryOk = country.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let rawUrl = "http://api.aladhan.com/v1/timingsByCity?city=\(cityOk)&country=\(countryOk)&method=14"
        
        let url = URL(string: rawUrl)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            NSLog("")
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            guard let dataJson = json["data"] as? [String: Any] else {
                return
            }
            let namazTimings = dataJson["timings"] as! [String: String]
            
            DispatchQueue.main.async {
                
                self.fadjrLabel.text = namazTimings["Fajr"]
                self.sunriseLabel.text = namazTimings["Sunrise"]
                self.zukhrLabel.text = namazTimings["Dhuhr"]
                self.asrLabel.text = namazTimings["Asr"]
                self.magribLabel.text = namazTimings["Maghrib"]
                self.ishaLabel.text = namazTimings["Isha"]
                
            }
            NSLog("")
            
        }
        
        task.resume()
        
    }
    
    
    
}

