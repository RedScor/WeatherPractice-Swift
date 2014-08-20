// Playground - noun: a place where people can play

import Cocoa

//let str = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=25.034298&lon=121.515432&cnt=7&units=imperial&mode=json"

let str = "http://api.openweathermap.org/data/2.5/forecast?lat=25.034298&lon=121.515432&units=imperial&cnt=12"

//let str = "http://api.openweathermap.org/data/2.5/weather?lat=25.034298&lon=121.515432&units=imperial"

let URL = NSURL(string: str)
let request = NSURLRequest(URL: URL)


var data = NSData.dataWithContentsOfURL(URL, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)

 var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: nil) as NSDictionary
println(dictionary)
let list = dictionary["list"] as NSArray
let dt = list[0]["dt"]
//var weatherSection: AnyObject = dictionary["weather"]!
//
//let weatherMain = weatherSection[0]!["icon"]

struct Stack<T> {
    var elements = [T]()
    
    mutating func push(element: T) {
        elements.append(element)
    }
    mutating func pop() -> T {
        return elements.removeLast()
        
    }
}

func swapMe<T>(inout a: T, inout b: T) {
    let temp = a
    a = b
    b = a
}

func swapMee<T>(inout a: T, inout b: T) {
    (a,b) = (b,a)
}
