//
//  SubmitRoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SubmitRoosterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var dagField1: UITextField!
    @IBOutlet weak var tijdField1: UITextField!
    @IBOutlet weak var dagField2: UITextField!
    @IBOutlet weak var tijdField2: UITextField!
    @IBOutlet weak var dagField3: UITextField!
    @IBOutlet weak var tijdField3: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    var textFieldSetBeingEdited: Int? = nil
    var shiftPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        var textFieldArray = [dagField1, tijdField1]
        
        shiftPicker.delegate = self
        shiftPicker.dataSource = self
        
        let length = textFieldArray.count
        
        for i in 0..<length
        {
            textFieldArray[i].tintColor = UIColor.clearColor()
            textFieldArray[i].inputView = shiftPicker
            textFieldArray[i].delegate = self
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitRooster()
    {
        let day = dagField1.text
        if let time = extractTimeComponents(tijdField1.text)
        {
            let hour = time.0
            let minute = time.1
            let rooster = Rooster()
            rooster.addRecurringShift(day, hour: hour, minute: minute)
        }
        
        dagField1.text = ""
        tijdField1.text = ""
    }
    
    func extractTimeComponents(time: String) -> (Int, Int)?
    {
        if time == ""
        {
            let timeArray = split(time) { $0 == ":" }
            var timeComponents: (Int, Int)
            
            timeComponents.0 = timeArray[0].toInt()!
            timeComponents.1 = timeArray[1].toInt()!
            
            return timeComponents
        }
        
        return nil
    }
    
    func updateTextField()
    {
        dagField1.text = pickerData[0][shiftPicker.selectedRowInComponent(0)]
        tijdField1.text = pickerData[1][shiftPicker.selectedRowInComponent(1)]
    }
    
    
    // protocols + data
    let pickerData = [
        ["Maandag","Dinsdag","Woensdag","Donderdag","Vrijdag","Zaterdag","Zondag"],
        ["15:00", "15:30", "16:30", "17:00", "18:00", "18:30"]
    ]
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        return pickerData[component][row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTextField()
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(textField.center.x - 7, textField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(textField.center.x + 7, textField.center.y))
        textField.layer.addAnimation(animation, forKey: "position")
        
        shiftPicker.selectRow(0, inComponent: 0, animated: true)
        shiftPicker.selectRow(0, inComponent: 1, animated: true)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}
