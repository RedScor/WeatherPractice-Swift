//
//  WeatherModel.swift
//  SimpleWeather-Swift
//
//  Created by RedScor Yuan on 2014/8/16.
//  Copyright (c) 2014年 RedScor Yuan. All rights reserved.
//

import Foundation

class WeatherModel {
    
    private let kelvin: Double
    private let kelvinMax: Double
    private let kelvinMin: Double
    let weatherMain: String
    let timeDate: NSDate
    let city: String
    var icon: String
    var formatter = NSNumberFormatter()

    var celsius: Double {
        
        return (kelvin - 32) * (5 / 9)
    }
    var celsiusMax: Double {
        
        return (kelvinMax - 32) * (5 / 9)
    }
    var celsiusMin: Double {
        
        return (kelvinMin - 32) * (5 / 9)
    }
    
    init(kelvinDegree: Double,kelvinMax: Double,kelvinMin: Double,cityName: String, iconImg:String, main:String,date:NSNumber) {
        
        kelvin = kelvinDegree
        self.kelvinMax = kelvinMax
        self.kelvinMin = kelvinMin
        city = cityName
        icon = iconImg
        weatherMain = main
        timeDate = NSDate(timeIntervalSince1970: date)

    }
    
    convenience init(temperatureDictionary: Dictionary<String,AnyObject>) {
        var mainSection: AnyObject = temperatureDictionary["main"]!
        var nameSection: AnyObject = temperatureDictionary["name"]!
        var weatherSection: AnyObject = temperatureDictionary["weather"]!
        
        var temperature = mainSection["temp"]
        var temperatureMax = mainSection["temp_max"]
        var temperatureMin = mainSection["temp_min"]
        var cityName = nameSection as String
        
        let kelvinValue = temperature as? Double
        let kelvinValueMax = temperatureMax as? Double
        let kelvinValueMin = temperatureMin as? Double

        let weatherMain = weatherSection[0]!["main"]
        let weathericon = weatherSection[0]!["icon"] as String

        self.init(kelvinDegree: kelvinValue!,kelvinMax: kelvinValueMax!,kelvinMin: kelvinValueMin! ,cityName: cityName, iconImg: weathericon,main: weatherMain as String ,date:0)
        
    }
    
    convenience init(dailyAndHourlyTemperDict: Dictionary<String,AnyObject>) {
        let dt:NSNumber = dailyAndHourlyTemperDict["dt"] as NSNumber
        
        var day: Double = 0.0
        var max: Double = 0.0
        var min: Double = 0.0
        if let temp = dailyAndHourlyTemperDict["temp"] as? NSDictionary {
            
            day = temp["day"] as Double
            max = temp["max"] as Double
            min = temp["min"] as Double
        } else {
            var temp = dailyAndHourlyTemperDict["main"] as NSDictionary
            day = temp["temp"] as Double

        }
        var weatherSection: AnyObject = dailyAndHourlyTemperDict["weather"]!
        let weathericon = weatherSection[0]!["icon"] as String
        
        self.init(kelvinDegree: day,kelvinMax: max,kelvinMin: min ,cityName: "", iconImg: weathericon,main: "" as String ,date:dt)

    }
    
    //MARK: image Dictionary
    class func imageMap() -> Dictionary<String,String>? {
        
        var _imageMap: Dictionary<String,String>?
        if _imageMap == nil {
            
            _imageMap = [
                "01d" : "weather-clear",
                "02d" :  "weather-few",
                "03d" :  "weather-few",
                "04d" :  "weather-broken",
                "09d" :  "weather-shower",
                "10d" :  "weather-rain",
                "11d" :  "weather-tstorm",
                "13d" :  "weather-snow",
                "50d" :  "weather-mist",
                "01n" :  "weather-moon",
                "02n" :  "weather-few-night",
                "03n" :  "weather-few-night",
                "04n" :  "weather-broken",
                "09n" :  "weather-shower",
                "10n" :  "weather-rain-night",
                "11n" :  "weather-tstorm",
                "13n" :  "weather-snow",
                "50n" :  "weather-mist",
            ]
        }
        return _imageMap
    }
    
    func imageName() -> String? {
        
        if let imgName = WeatherModel.imageMap()![self.icon] {
            return imgName
        }else {
            return nil
        }
    }
}
