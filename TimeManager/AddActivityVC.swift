//
//  AddActivityVC.swift
//  TimeManager
//
//  Created by Trong Nghia Hoang on 5/30/17.
//  Copyright © 2017 Trong Nghia Hoang. All rights reserved.
//

import UIKit
import CoreData

class AddActivityVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {

    // MARK: - Variables
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UIView!
    
    var color: String = ""
    var thumb: String = ""
    var type: String = ""
    
    var itemToEdit: Activity?
    
    let thumbArray = ["build", "car", "code", "eat", "film", "friends", "game", "guitar", "gym", "other", "phone", "run", "shopping",  "shower",  "sleep"]
    
    let colorArray = ["18a4f7", "7ecf35", "fa9d15", "f73b76", "9c6dbb", "b18558", "f23c39", "0a94bb", "f58883", "ff8a02", "fad119", "89c5bb", "b1bd35"]
    
    // MARK: - View Handler
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customize()
    }
    
    
    // MARK: - Initialization
    func customize() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let leftIcon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem.init(image: leftIcon!, style: .plain, target: self, action: #selector(self.dismissSelf))
        self.navigationItem.leftBarButtonItem = backButton
        let rightIcon = UIImage.init(named: "done")?.withRenderingMode(.alwaysOriginal)
        let doneButton = UIBarButtonItem.init(image: rightIcon!, style: .plain, target: self, action: #selector(self.saveData))
        self.navigationItem.rightBarButtonItem = doneButton
        hideKeyboardWhenTappedAround()
        typeCollectionView.allowsMultipleSelection = false
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // MARK: - TextField Handler
    func textDidChange(textField: UITextField) {
        if nameTextField.text!.isEmpty {
            nameLabel.backgroundColor = UIColor.red
        } else {
            nameLabel.backgroundColor = UIColor.lightGray
        }
    }
    
    // MARK: - View Dismiss Handler
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    // MARK: - Core Data
    func saveData() {
        if nameTextField.text!.isEmpty {
            nameLabel.backgroundColor = UIColor.red
        } else if color == "" {
            colorLabel.textColor = UIColor.red
            colorLabel.text = "Please select Color"
        } else if thumb == "" {
            typeLabel.text = "Please select Type"
            typeLabel.textColor = UIColor.red
        } else {
            let date = Date()
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            let b = timeFormatter.string(from: date)
            
            if thumb == "film" || thumb == "game"  || thumb == "phone" {
                type = "Entertain"
            } else if thumb == "code" || thumb == "build" {
                type = "Work"
            } else if thumb == "sleep" || thumb  == "eat" || thumb == "shower" {
                type = "Essential"
            } else if thumb == "guitar" {
                type = "Music"
            } else  if thumb == "run" || thumb == "gym" {
                type = "Fitness"
            } else if thumb == "car" {
                type = "Transport"
            }  else if thumb == "shopping" || thumb == "friends" {
                type = "Outdoor"
            } else {
                type = "Other"
            }
            
            
            var activity: Activity!

            
            if itemToEdit == nil {
                activity = Activity(context: context)
                activity.activityDescription = nameTextField.text
                activity.from = NSDate()
                activity.color = color
                activity.thumbnail = thumb
                activity.day = Date() as NSDate
                activity.title = b
                activity.type = type
            } else {
                activity = itemToEdit
                let activityFromCheck = Calendar.current.component(.day, from: activity.from! as Date)
                let activityToCheck = Calendar.current.component(.day, from: Date())
                if activityFromCheck != activityToCheck {
                    activity.to = (activity.from! as Date).endOfDay! as NSDate
                    var activity1 = Activity(context: context)
                    activity1.activityDescription = activity.activityDescription
                    activity1.from = Date().startOfDay as NSDate
                    activity1.to = NSDate()
                    activity1.color = activity.color
                    activity1.thumbnail = activity.thumbnail
                    activity1.day = Date() as NSDate
                    activity1.title = "12:00 AM"
                    activity1.type = activity.type
                    ad.saveContext()
                    defer {
                        var activity2 = Activity(context: context)
                        activity2.activityDescription = nameTextField.text
                        activity2.from = NSDate()
                        activity2.color = color
                        activity2.thumbnail = thumb
                        activity2.day = Date() as NSDate
                        activity2.title = b
                        activity2.type = type
                    }
                } else {
                    activity?.to = NSDate()
                    activity = Activity(context: context)
                    activity.activityDescription = nameTextField.text
                    activity.from = NSDate()
                    activity.color = color
                    activity.thumbnail = thumb
                    activity.day = Date() as NSDate
                    activity.title = b
                    activity.type = type
                }
            }
            
            ad.saveContext()
            navigationController?.popViewController(animated: true)
        }
    }

    //MARK: - ColletionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.typeCollectionView {
            return 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.typeCollectionView {
            return thumbArray.count
        } else {
            return colorArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.typeCollectionView {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            let imageView: UIImageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 26, height: 26))
            let image: UIImage = UIImage(named: thumbArray[indexPath.row])!
            imageView.image = image
            cell.contentView.addSubview(imageView)
            return cell
        } else {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
            cell.backgroundColor = UIColor(hexString: colorArray[indexPath.row])
            return cell
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.typeCollectionView {
            let cell = typeCollectionView.cellForItem(at: indexPath)
            cell?.layer.borderColor = UIColor(hexString: "7263e0").cgColor
            cell?.layer.borderWidth = 1
            typeLabel.textColor = UIColor.lightGray
            typeLabel.text = "Type"
            thumb = thumbArray[indexPath.row]
        } else {
            colorLabel.text = "Color"
            colorLabel.textColor = UIColor(hexString: colorArray[indexPath.row])
            color = colorArray[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.typeCollectionView {
            let cell = typeCollectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 1
            cell?.layer.borderColor = UIColor.white.cgColor
        } else {
            colorLabel.textColor = UIColor.lightGray
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Extension
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
}
