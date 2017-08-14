//
//  TimelineVC.swift
//  TimeManager
//
//  Created by Trong Nghia Hoang on 5/29/17.
//  Copyright © 2017 Trong Nghia Hoang. All rights reserved.
//

import UIKit
import CoreData
import TimelineTableViewCell
import Charts
import SwiftSpinner
import CoreMotion
import CoreLocation

class TimelineVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var timelineTblView: UITableView!
    @IBOutlet var noDataView: UIView!
    @IBOutlet weak var addNewBtn: UIButton!
    
    @IBOutlet weak var switchViewBtn: UIBarButtonItem!
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tempLabel: UILabel!
    
    var lastChartSectionIndex = Int()

    var blink: Bool = false

    var fetchedDay: NSFetchedResultsController<Day>!
    var fetchedActivity: NSFetchedResultsController<Activity>!

    var daysArray = [String]()
    var activitiesArray = [(Date, Array<Activity>)]()
    
    var viewType: String = ""
    
    struct Item {
        let value : Int
        let name: String
    }
    
    // MARK: - View Handler
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timelineTblView.delegate = self
        self.timelineTblView.dataSource = self
        scheduledTimerWithTimeInterval()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.timelineTblView.delegate = self
        self.timelineTblView.dataSource = self
        viewType = "timeline"
        initData()
        setupLocationManager()
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Initialization
    func initData() {
        SwiftSpinner.show("Fetching data...")
        initTimeline()
        fetchActivityFromCoreData()
        let activities = fetchActivityDetails()
        activitiesArray =  groupActivityByDay(activities: activities)
        lastChartSectionIndex = timelineTblView.numberOfSections - 1
        timelineTblView.reloadData()
        if !activitiesArray.isEmpty {
            lastChartSectionIndex = timelineTblView.numberOfSections - 1
            tableViewScrollToBottom(animated: true)
        }
        defer {
        }
        
    }
    
    func initTimeline() {
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
                                             bundle: Bundle(url: nibUrl!)!)
        timelineTblView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        self.timelineTblView.estimatedRowHeight = 300
        self.timelineTblView.rowHeight = UITableViewAutomaticDimension
    }
    
    func initChart(index: Int) {
        // Then grab the number of rows in the last section
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eee, MMM dd, yyyy"
        
        var resultArray = [Item]()
        var dataArray = [Item]()
        lastChartSectionIndex = index
        var allKeys = Set<String>()
        if !activitiesArray.isEmpty {
            for i in 0..<activitiesArray[lastChartSectionIndex].1.count - 1 {
                let days = activitiesArray[lastChartSectionIndex].1[i]
                let activityFrom = days.from
                let activityTo = days.to
                var different = 0
                
                different = secondFromTimeInterval(interval: (activityTo!.timeIntervalSince(activityFrom! as Date)))
                
                
                dataArray.append(Item(value: different, name: days.type!))
                
                
                
            }
            allKeys = Set<String>(dataArray.filter({!($0.name.isEmpty)}).map{$0.name})
            
            
            for key in allKeys {
                let sum = dataArray.filter({$0.name == key}).map({$0.value}).reduce(0, +)
                resultArray.append(Item(value: sum, name: key))
            }
            
            if lastChartSectionIndex == 0 || timelineTblView.numberOfSections == 1 {
                backBtn.isHidden = true
                nextBtn.isHidden = false
            } else if lastChartSectionIndex == timelineTblView.numberOfSections - 1 {
                nextBtn.isHidden = true
                backBtn.isHidden = false
            } else {
                nextBtn.isHidden = false
                backBtn.isHidden = false
            }
            
            setUpChart(data: resultArray)
            pieChartView.chartDescription?.enabled = false
            pieChartView.rotationEnabled = false
            pieChartView.legend.enabled = false
            pieChartView.holeRadiusPercent = CGFloat(0.3)
            pieChartView.transparentCircleRadiusPercent = CGFloat(0.4)
            dayLabel.text = dateFormatter.string(from: (activitiesArray[index].0) as Date)
            
        }
    }
    
    func setUpChart(data: [Item]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<data.count {
            let dataEntry1 = PieChartDataEntry(value: Double(data[i].value), label: "\(data[i].name.capitalized)\n\(stringFromTimeInterval(interval: TimeInterval(data[i].value)))")
            dataEntries.append(dataEntry1)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.drawValuesEnabled = false
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for i in 0..<data.count {
            let colorArray = ["18a4f7", "7ecf35", "fa9d15", "f73b76", "9c6dbb", "b18558", "f23c39", "0a94bb", "f58883", "ff8a02", "fad119", "89c5bb", "b1bd35"]
            let color = UIColor(hexString: colorArray[i])
            
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
    }
    
    // MARK: - Tableview
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.timelineTblView.numberOfSections
            let numberOfRows = self.timelineTblView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.timelineTblView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                SwiftSpinner.hide()
            }
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if activitiesArray.count != 0 {
            numOfSections = activitiesArray.count
        } else {
            addNewBtn.layer.cornerRadius = addNewBtn.frame.width / 2
            addNewBtn.layer.masksToBounds = true
            addNewBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 10, 10)
            tableView.backgroundView  = noDataView
            tableView.separatorStyle  = .none
            numOfSections = 0
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eee, MMM dd, yyyy"
        
        return dateFormatter.string(from: (activitiesArray[section].0) as Date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesArray[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timelineTblView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell
        
        let activity = activitiesArray[indexPath.section].1[indexPath.row]
        
        var different = ""
        var timelineFrontColor = UIColor.clear
        
        if (indexPath.row > 0) {
            timelineFrontColor = UIColor(hexString:activitiesArray[indexPath.section].1[indexPath.row - 1].color!)
        }
        
        if activity.to != nil {
            different = stringFromTimeInterval(interval: (activity.to?.timeIntervalSince(activity.from! as Date))!) as String
        } else {
            //different = stringFromTimeInterval(interval: (Date().timeIntervalSince(activity.from! as Date))) as String + "\nOngoing"
            different = stringFromTimeInterval(interval: (Date().timeIntervalSince(activity.from! as Date))) as String
        }
        
        
        if activity.to != nil {
            cell.timelinePoint = TimelinePoint()
            cell.statusImageView.image = nil
        } else {
            cell.statusImageView.image = UIImage.gif(name: "ongoing")
            if blink == false {
                cell.timelinePoint = TimelinePoint()
                blink = true
            } else {
                cell.timelinePoint = TimelinePoint(color: UIColor(hexString: activity.color!), filled: true)
                blink = false
            }
        }
        
        
        cell.timeline.frontColor = timelineFrontColor
        cell.timeline.backColor = UIColor(hexString: activity.color!)
        cell.titleLabel.text = activity.title
        cell.thumbnailImageView.image = UIImage(named: activity.thumbnail!)
        cell.descriptionLabel.text = activity.activityDescription
        if different != "" {
            cell.lineInfoLabel.text = different
            cell.lineInfoLabel.textAlignment = .center
        }
        
        let lastSectionIndex = timelineTblView!.numberOfSections - 1
        
        // Then grab the number of rows in the last section
        let lastRowIndex = timelineTblView!.numberOfRows(inSection: lastSectionIndex) - 1
        
        let lastCellIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        
        if indexPath == lastCellIndexPath {
            cell.lineInfoLabel.text = different
        }
        
        return cell
    }
    
    
    func refresh() {
        self.timelineTblView.reloadData()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
    }
    
    // MARK: - Supporting Function
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "  %0.2dh%0.2dm",hours,minutes)
    }
    
    func secondFromTimeInterval(interval: TimeInterval) -> Int {
        let ti = NSInteger(interval)
        
        //let seconds = (ti % 60)
        
        return ti
    }
    
    // MARK: - Core Data
    func fetchActivityFromCoreData() {
        let activityRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
        
        let activitySort = NSSortDescriptor(key: "from", ascending: false)
        
        activityRequest.sortDescriptors = [activitySort]
        
        let activityController = NSFetchedResultsController(fetchRequest: activityRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        activityController.delegate = self
        
        self.fetchedActivity = activityController
        
        
        do {
            try activityController.performFetch()
        } catch {
            let error = error as NSError
            print("Error: \(error)")
        }
    }
    
    func fetchActivityDetails() -> [Activity] {
        var activitiesList = [Activity]()
        let activityRequest : NSFetchRequest<Activity> = Activity.fetchRequest()
        do {
            var activities = [Activity]()
            activities = try context.fetch(activityRequest)
            var activity: Activity?
            for i in 0..<activities.count {
                activity = activities[i]
                activitiesList.append(activity!)
            }
        } catch {
            print("error")
        }
        return activitiesList
    }
    
    func groupActivityByDay(activities: [Activity]) -> [(Date, Array<Activity>)]{
        var activitiesDict = Dictionary<Date, Array<Activity>>()
        for activity in activities {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "eee, MMM dd, yyyy"
            let a = dateFormatter.string(from: (activity.day)! as Date)
            
            let date = dateFormatter.date(from: a)
            //let date: Date = activity.day! as Date
            if activitiesDict[date!] == nil {
                activitiesDict[date!] = Array<Activity>()
            }
            activitiesDict[date!]?.append(activity)
        }
        return activitiesDict.sorted { $0.0 < $1.0 }
    }

    
    // MARK: - Button
    @IBAction func addNewBtn_Pressed(_ sender: UIButton) {
        //only takes date
        let date = Date()
        
        var addedDay: Day!
        addedDay = Day(context: context)
        addedDay.day = date as NSDate
        ad.saveContext()
    }
    
    @IBAction func switchViewBtn_Pressed(_ sender: UIBarButtonItem) {
        if viewType == "timeline" {
            viewType = "piechart"
            switchViewBtn.image = UIImage(named: "list")
            timelineTblView.isHidden = true
            initChart(index: lastChartSectionIndex)
        } else {
            viewType = "timeline"
            switchViewBtn.image = UIImage(named: "piechart")
            timelineTblView.isHidden = false
        }
    }
    
    @IBAction func nextBtn_Pressed(_ sender: UIButton) {
        if !activitiesArray.isEmpty {
            lastChartSectionIndex = lastChartSectionIndex + 1
            initChart(index: lastChartSectionIndex)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "eee, MMM dd, yyyy"
            
            dayLabel.text = dateFormatter.string(from: (activitiesArray[lastChartSectionIndex].0) as Date)
        }
    }
    
    @IBAction func backBtn_Pressed(_ sender: UIButton) {
        if !activitiesArray.isEmpty {
            lastChartSectionIndex = lastChartSectionIndex - 1
            initChart(index: lastChartSectionIndex)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "eee, MMM dd, yyyy"
            
            dayLabel.text = dateFormatter.string(from: (activitiesArray[lastChartSectionIndex].0) as Date)
        }
    }
    
    @IBAction func addNewActivityBtn(_ sender: UIBarButtonItem) {
        if activitiesArray.count > 0 {
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "newActivity")
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if activitiesArray.count > 0 {
            if segue.identifier == "addActivity" {
                let lastSectionIndex = timelineTblView!.numberOfSections - 1
                
                // Then grab the number of rows in the last section
                let lastRowIndex = timelineTblView!.numberOfRows(inSection: lastSectionIndex) - 1
                
                // Make the last row visible
                let item = activitiesArray[lastSectionIndex].1[lastRowIndex]
                
                if let destination = segue.destination as? AddActivityVC {
                    destination.itemToEdit = item
                }
            }
        }
    }
    
    // MARK: - Motion Detector
    private let clLocationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    var tempSpeed = Double()
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        tempSpeed = locations[0].speed
        print("speed: \(locations[0].speed)")
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        print("\(error)")
    }
    
    // Setup Location Manager
    private func setupLocationManager() {
        clLocationManager.delegate = self
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        clLocationManager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *){
            clLocationManager.allowsBackgroundLocationUpdates = true
        }
        clLocationManager.startUpdatingLocation()
    }
    
    func motionDetector() {
        motionActivityManager
            .startActivityUpdates(to: OperationQueue.main) { (activity) in
                var types = ""
                if (activity?.automotive)! {
                    print("User using car")
                    types.append("Car\n")
                }
                if (activity?.cycling)! {
                    print("User is cycling")
                    types.append("Cycling\n")
                }
                if (activity?.running)! {
                    print("User is running")
                    types.append("Running\n")
                }
                if (activity?.walking)! {
                    print("User is walking")
                    types.append("Walking\n")
                }
                if (activity?.stationary)! {
                    print("User is standing")
                    types.append("Stationary\n")
                }
                if (activity?.unknown)! {
                    types.append("Unknown\n")
                }
                let confi = activity?.confidence.rawValue
                print("confi:\(confi!)")
                print(types)
                self.dayLabel.text = "\(types) xxx \(self.tempSpeed)"
        }
    }
}
