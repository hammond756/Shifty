//
//  SubmitRoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SubmitRoosterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{    
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var textFieldSetBeingEdited: Int? = nil
    var shiftPicker = UIPickerView()
    let rooster = Rooster()
    
    // set properties of UI elements and asign the delegate/datasource of the UIPickerView
    override func viewDidLoad()
    {
        switchStateOfActivityView(false)
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        var textFieldArray = [dayField, timeField]
        
        shiftPicker.delegate = self
        shiftPicker.dataSource = self
        
        for i in 0..<textFieldArray.count
        {
            textFieldArray[i].tintColor = UIColor.clearColor()
            textFieldArray[i].inputView = shiftPicker
            textFieldArray[i].delegate = self
        }
                
        super.viewDidLoad()
    }
    
    // send the day and time to the Rooster() class for processing to the database
    @IBAction func submitRooster()
    {
        let day = dayField.text
        
        if let time = extractTimeComponents(timeField.text)
        {
            switchStateOfActivityView(true)
            rooster.registerFixedShift(day, hour: time[0], minute: time[1]) { shift -> Void in
                if let shift = shift
                {
                    self.rooster.generateInitialShifts(shift) { () -> Void in
                        self.switchStateOfActivityView(false)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                else
                {
                    self.switchStateOfActivityView(false)
                    let alertView = UIAlertController(title: nil, message: "Je hebt al een dienst op deze dag", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ohja", style: .Cancel) { action -> Void in
                        alertView.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alertView.addAction(cancelAction)
                    alertView.popoverPresentationController?.sourceView = self.view
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
                
            }
        }
        
        dayField.text = ""
        timeField.text = ""
    }
    
    func switchStateOfActivityView(on: Bool)
    {
        on ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityView.hidden = !on
    }
    
    // get two integers [hour, minute] from string format HH:mm
    private func extractTimeComponents(time: String) -> [Int]?
    {
        if time != ""
        {
            let timeArray = split(time) { $0 == ":" }
            return timeArray.map { $0.toInt()! }
        }
        
        return nil
    }
    
    // put info on selected picker rows in the textfields
    func updateTextFields()
    {
        dayField.text = Constant.pickerData[0][shiftPicker.selectedRowInComponent(0)]
        timeField.text = Constant.pickerData[1][shiftPicker.selectedRowInComponent(1)]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Constant.pickerData[component].count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return Constant.pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        return Constant.pickerData[component][row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        updateTextFields()
    }
    
    // show animation to give feedback that editing began
    func textFieldDidBeginEditing(textField: UITextField)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(textField.center.x - 7, textField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(textField.center.x + 7, textField.center.y))
        textField.layer.addAnimation(animation, forKey: "position")
        
        shiftPicker.selectRow(4, inComponent: 0, animated: true)
        shiftPicker.selectRow(4, inComponent: 1, animated: true)
    }
    
    // tap outside textfield to end editing
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}
