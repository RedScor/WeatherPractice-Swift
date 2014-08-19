//
//  APIClient.swift
//  SimpleWeather-Swift
//
//  Created by RedScor Yuan on 2014/8/16.
//  Copyright (c) 2014年 RedScor Yuan. All rights reserved.
//

import UIKit
import CoreLocation

protocol fetchforecastDelegate {
    
    func fetchDailyforecastWithLatitude(success: Bool,item:[WeatherModel]?)
    func fetchHourlyforecastWithLatitude(success: Bool,item:[WeatherModel]?)
}

class APIClient: NSObject
{
    let baseURLString = "http://api.openweathermap.org/data/2.5"
    let weatherPathFormat = "/weather?lat=%f&lon=%f&units=imperial"
    let dailyforecastPathFormat = "/forecast/daily?lat=%f&lon=%f&cnt=7&units=imperial&mode=json"
    let hourlyforecastPathFormat = "/forecast?lat=%f&lon=%f&units=imperial&cnt=12"
    
    var fetchDelegate: fetchforecastDelegate?
    var queue: NSOperationQueue = NSOperationQueue()
    
    //MARK: fetchDailyData  Use NSURLConnection and Closure, input lat,lng and Callback
    func fetchWeatherWithLatitude(latitude: Double, longitude: Double, completion:((WeatherModel?) -> Void)!) {
        
        let URLString = baseURLString.stringByAppendingFormat(weatherPathFormat, latitude, longitude)
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if (response == nil) {
                completion(nil)
                return;
            }
            
            var jsonError: NSError? = nil
            var dictionary : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError)
            
            dispatch_async(dispatch_get_main_queue(), {
                var item = WeatherModel(temperatureDictionary: dictionary as Dictionary)
                completion(item);
            })
        })
    }
    
    //MARK: fetchDailyData  Use NSURLConnection and Delegate, input lat and lng
    func fetchDailyforecastForLatitude(lat: Double,lng: Double) {
        let URLString = baseURLString.stringByAppendingFormat(dailyforecastPathFormat, lat, lng)
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if (response == nil) {
                self.fetchDelegate!.fetchDailyforecastWithLatitude(false, item: nil)
                return;
            }
            
            var jsonError: NSError? = nil
            var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &jsonError) as NSDictionary
            
            dispatch_async(dispatch_get_main_queue(), {
                let list = dictionary["list"] as NSArray
                var items = [WeatherModel]()

                list.enumerateObjectsUsingBlock({ object, index, stop in
                    var listItem = object as NSDictionary
//                    let dt:NSNumber = listItem.objectForKey("dt") as NSNumber
//                    
//                    var temp = listItem["temp"] as NSDictionary
//                    var day: Double = temp["day"] as Double
//                    var max: Double = temp["max"] as Double
//                    var min: Double = temp["min"] as Double
//                    var weatherSection: AnyObject = listItem["weather"]!
//                    let weathericon = weatherSection[0]!["icon"] as String
//
                    
                    var weatherItem = WeatherModel(dailyAndHourlyTemperDict: listItem as Dictionary)
                    
                    items.append(weatherItem)
                })
                
                self.fetchDelegate?.fetchDailyforecastWithLatitude(true, item: items)
                
            })
        })
        
    }
    
    //MARK: fetchHourlyData  Use NSURLSession and Delegate , input CLLocationCoordinate2D
    func fetchHourlyForecastForLocation(coordinate :CLLocationCoordinate2D)
    {
        
        let URLString = baseURLString.stringByAppendingFormat(hourlyforecastPathFormat, coordinate.latitude, coordinate.longitude)
        let URL = NSURL(string: URLString)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let sessionConn = NSURLSession(configuration: config)
        
        let dataTask: NSURLSessionDataTask = sessionConn.dataTaskWithURL(URL, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (response == nil) {
                self.fetchDelegate!.fetchHourlyforecastWithLatitude(false, item: nil)
                return;
            }
            
            var jsonError: NSError? = nil
            var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &jsonError) as NSDictionary
            
            dispatch_async(dispatch_get_main_queue(), {
                let list = dictionary["list"] as NSArray
                var items = [WeatherModel]()
                
                list.enumerateObjectsUsingBlock({ (object , index , stop) -> Void in
                    var listItem = object as NSDictionary
//                    let dt:NSNumber = listItem.objectForKey("dt") as NSNumber
//                    
//                    var temp = listItem["main"] as NSDictionary
//                    var day: Double = temp["temp"] as Double
//                    var weatherSection: AnyObject = listItem["weather"]!
//                    let weathericon = weatherSection[0]!["icon"] as String
                    
                    let model: WeatherModel = WeatherModel(dailyAndHourlyTemperDict: listItem as Dictionary)
                    items.append(model)

                })
                
                self.fetchDelegate?.fetchHourlyforecastWithLatitude(true, item: items)

            })
            
        })
        dataTask.resume()

    }
}
