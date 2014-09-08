//
//  ViewController.swift
//  SimpleWeather-Swift
//
//  Created by RedScor Yuan on 2014/8/16.
//  Copyright (c) 2014年 RedScor Yuan. All rights reserved.
//

import UIKit

 class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView! = UIImageView()
//    var blurredImageView: UIImageView?
    @IBOutlet var tableView: UITableView! = UITableView()
    
    @IBOutlet weak var cityLabel: UILabel! = UILabel()
    @IBOutlet weak var iconView: UIImageView! = UIImageView()
    @IBOutlet weak var conditionsLabel: UILabel! = UILabel()
    @IBOutlet weak var temperatureLabel: UILabel! = UILabel()
    @IBOutlet weak var hiloLabel: UILabel! = UILabel()
    let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    var screenHeight: CGFloat
    let client = APIClient()
    
    required init(coder aDecoder: NSCoder) {
        screenHeight = 0
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCurrentCondition", name: "fetchNowForecast", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getHourlyForecast", name: "fetchHourlyForecast", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getDailyForecast", name: "fetchDailyForecast", object: nil)

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = self.view.bounds
        blurView.alpha = 0.0;
        view.addSubview(blurView)
        self.view .bringSubviewToFront(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = UIColor.redColor()
        screenHeight = UIScreen.mainScreen().bounds.size.height

        let manager = WeatherManager.instance
        manager.findCurrentLocation()

    }

    func getCurrentCondition() {
        println("getCurrentCondition")
        let manager = WeatherManager.instance.currentConditionData
        cityLabel.text = manager?.city
        iconView.image = UIImage(named: manager!.imageName()!)
        conditionsLabel.text = manager?.weatherMain
        temperatureLabel.text = "\(Int(manager!.celsius))°"
        hiloLabel.text = "\(manager!.celsiusMax)°/\(manager!.celsiusMin)°"
        
    }
    
    func getHourlyForecast() {
        println("getHourlyForecast")
        tableView.reloadData()
    }
    
    func getDailyForecast() {
        println("getDailyForecast")
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if let hourlyCount =  WeatherManager.instance.hourlyForecastData?.count {
                return min(hourlyCount, 6) + 1
            }
        }
        if let dailyCount = WeatherManager.instance.dailyForecastData?.count {
            return min(dailyCount, 6) + 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cellIdentifier"
//        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
//        if cell == nil {
//            cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
//        }
        cell.selectionStyle = .None
    
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        
        if indexPath.row == 0 {
            configureHeaderCell(cell, titleIndex: indexPath.section)
        } else {
            var model: WeatherModel?
            
            if indexPath.section == 0 {
                model = WeatherManager.instance.hourlyForecastData?[indexPath.row - 1] as? WeatherModel
            }else {
                model = WeatherManager.instance.dailyForecastData?[indexPath.row - 1] as? WeatherModel
            }
            
            let selectCell = selectHourlyAndDailyCell(indexPath.section)
            if let dataModel = model {
                selectCell(cell, dataModel)
            }
        }

        return cell
    }

    func configureHeaderCell(cell: UITableViewCell,titleIndex:Int) {
        
        var titleStr: String
        if titleIndex == 0 {
            titleStr = "Hourly Forecast"
        }else {
            titleStr = "Daily Forecast"

        }
        cell.textLabel!.font = UIFont.systemFontOfSize(18.0)
        cell.textLabel!.text = titleStr
        cell.detailTextLabel!.text = ""
        cell.imageView!.image = nil
    }
    
    
    func selectHourlyAndDailyCell(cellSection:Int) -> (UITableViewCell,WeatherModel) -> Void {
        func configureHourlyCell(cell:UITableViewCell,weather:WeatherModel) {
            cell.textLabel!.font = UIFont.systemFontOfSize(18)
            cell.detailTextLabel!.font = UIFont.systemFontOfSize(18)
            cell.textLabel!.text = WeatherManager.instance.hourlyFormatter.stringFromDate(weather.timeDate)
            cell.detailTextLabel!.text = NSString(format: "%.1f°", weather.celsius)
            if let image = weather.imageName() {
                cell.imageView!.image = UIImage(named: image)
            }else {
                cell.imageView?.image = nil
            }
            cell.imageView!.contentMode = .ScaleAspectFit
        }
        
        func configureDailyCell(cell: UITableViewCell,weather: WeatherModel) {
            cell.textLabel!.font = UIFont.systemFontOfSize(18)
            cell.detailTextLabel!.font = UIFont.systemFontOfSize(18)
            cell.textLabel!.text = WeatherManager.instance.dailyFormatter.stringFromDate(weather.timeDate)
            cell.detailTextLabel!.text = NSString(format: "%.0f° / %.0f°", weather.celsiusMax,weather.celsiusMin)
            if let image = weather.imageName() {
                cell.imageView!.image = UIImage(named: image)
            }else {
                cell.imageView?.image = nil
            }
            cell.imageView!.contentMode = .ScaleAspectFit
        }
        
        return cellSection == 0 ? configureHourlyCell : configureDailyCell
    }
    
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {

        let cellCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        return self.screenHeight / CGFloat(cellCount);

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

       let bounds : CGRect  = view.bounds
        
        backgroundImageView!.frame = bounds
        tableView.frame = bounds
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let height:CGFloat = scrollView.bounds.size.height;
        let position:CGFloat = max(scrollView.contentOffset.y, 0.0);
        
        // 2.偏移量除以高度，並且最大值為1，所以alpha上限為1。
        let percent:CGFloat = min(position / height, 1.0);
        
        // 3.當你滾動的時候，把結果值賦給模糊圖像的alpha屬性，來更改模糊圖像。
        self.blurView.alpha = percent;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

