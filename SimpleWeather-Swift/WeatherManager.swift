//
//  WeatherManager.swift
//  SimpleWeather-Swift
//
//  Created by RedScor Yuan on 2014/8/17.
//  Copyright (c) 2014年 RedScor Yuan. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherManager: NSObject,CLLocationManagerDelegate,fetchforecastDelegate {
   
    private var currentLocation: CLLocation? {
        didSet{
            updateCurrentConditions()
            updateDailyForecast()
            updateHourlyForecast()
        }
    }
    private var dailyForecast: [AnyObject]?
    private var hourlyForecast: [AnyObject]?
    private var currentCondition: WeatherModel?
    
    let dailyFormatter = NSDateFormatter()
    let hourlyFormatter = NSDateFormatter()
    
    var dailyForecastData:[AnyObject]? {
        
        return dailyForecast ?? dailyForecast
    }
    var hourlyForecastData:[AnyObject]? {
        
        return hourlyForecast ?? hourlyForecast
    }
    var currentConditionData:WeatherModel? {
        return currentCondition ?? currentCondition
    }
    
    var locationManager = CLLocationManager()
    var isFirstUpdate: Bool = true
    var client = APIClient()
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        client.fetchDelegate = self
        
        hourlyFormatter.dateFormat = "h a"
        dailyFormatter.dateFormat = "EEEE"

    }
    
    class var instance: WeatherManager {
        
        struct SingletonInstance {
        
            static let i = WeatherManager()
        }
        return SingletonInstance.i
    }
    
    func findCurrentLocation() {
        isFirstUpdate = true
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if self.isFirstUpdate == true {
            self.isFirstUpdate = false
            return
        }
        let location: CLLocation = locations.last! as CLLocation
        if location.horizontalAccuracy > 0 {
            self.currentLocation = location
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    
    // MARK: fetch Daily Data
    func updateDailyForecast() {
        self.client.fetchDailyforecastForLatitude(self.currentLocation!.coordinate.latitude, lng: self.currentLocation!.coordinate.longitude)
    }
    
    func fetchDailyforecastWithLatitude(success: Bool, item: [WeatherModel]?) {
        if item != nil{
            self.dailyForecast = item!
            NSNotificationCenter.defaultCenter().postNotificationName("fetchDailyForecast", object: nil)

        }
    }

    // MARK: fetch Hourly Data
    func updateHourlyForecast() {
        self.client.fetchHourlyForecastForLocation(self.currentLocation!.coordinate)
    }
    
    func fetchHourlyforecastWithLatitude(success: Bool, item: [WeatherModel]?) {
        if item != nil{
            self.hourlyForecast = item!
            NSNotificationCenter.defaultCenter().postNotificationName("fetchHourlyForecast", object: nil)

        }
    }
    // MARK: fetch Now Data
    func updateCurrentConditions() {
        self.client.fetchWeatherWithLatitude(self.currentLocation!.coordinate.latitude,
            longitude: self.currentLocation!.coordinate.longitude) { item in
                
                if let item = item {
                    self.currentCondition = item
                    NSNotificationCenter.defaultCenter().postNotificationName("fetchNowForecast", object: nil)
                }
        }
    }
    
}
