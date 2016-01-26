//
//  SubmitRoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Let's the user select a day and time for one of their fixed shifts via
//  a UIPickerView. This can be done one at a time. Automatically pop off the
//  UINavigationController's stack when done uploading.

import UIKit
import Parse

class SubmitRoosterViewController: UIViewController
{    
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var shiftPicker = UIPickerView()
    let rooster = Rooster()
    
    // set properties of UI elements and asign the delegate/datasource of the UIPickerView
    override func viewDidLoad()
    {
        setActivityViewActive(false)
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        shiftPicker.delegate = self
        shiftPicker.dataSource = self
        
        var textFields = [dayField, timeField]
        for i in 0..<textFields.count
        {
            textFields[i].tintColor = UIColor.clearColor()
            textFields[i].inputView = shiftPicker
            textFields[i].delegate = self
        }
                
        super.viewDidLoad()
    }
    
    // send the day and time to the Rooster() class for processing to the database
    @IBAction func submitRooster()
    {
        if dayField.text != "" && timeField.text != ""
        {
            setActivityViewActive(true)
            
            let day = dayField.text
            var time = extractTimeComponents(timeField.text)
            
            // save fixed shift, and generete eight weeks ahead. (after checking for double entries)
            rooster.registerFixedShift(day, hour: time[0], minute: time[1]) { shift -> Void in
                if let shift = shift
                {
                    self.rooster.generateInitialShifts(shift) { () -> Void in
                        self.setActivityViewActive(false)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                    // else show message to alert user that the shift wasn't registered
                else
                {
                    self.setActivityViewActive(false)
                    self.showAlertMessage("Je hebt al een dienst op deze dag")
                }
            }
        }
        
        dayField.text = ""
        timeField.text = ""
    }
    
    // create and present alertView with supplied message and cancel button
    func showAlertMessage(message: String)
    {
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Ohja", style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertView.addAction(cancelAction)
        alertView.popoverPresentationController?.sourceView = self.view
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    // toggle activity indicator view on (true) off (false)
    func setActivityViewActive(on: Bool)
    {
        on ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityView.hidden = !on
    }
    
    // get two integers [hour, minute] from string format HH:mm
    func extractTimeComponents(time: String) -> [Int]
    {
        let timeArray = time.characters.split { $0 == ":" }.map { String($0) }
        return timeArray.map { Int($0)! }
    }
    
    // put info on selected picker rows in the textfields
    func updateTextFields()
    {
        dayField.text = Constant.pickerData[0][shiftPicker.selectedRowInComponent(0)]
        timeField.text = Constant.pickerData[1][shiftPicker.selectedRowInComponent(1)]
    }
    
    // tap outside textfield to end editing
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}

// UIPickerView delegate and datasource functions
extension SubmitRoosterViewController: UIPickerViewDataSource, UIPickerViewDelegate
{
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
}

// UITextField delegate functions
extension SubmitRoosterViewController: UITextFieldDelegate
{
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
}
