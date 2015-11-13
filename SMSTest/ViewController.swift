//
//  ViewController.swift
//  SMSTest
//
//  Created by Adam Rais on 15/09/2015.
//  Copyright © 2015 Adamgoodapp. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class ViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {
    
    
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let authorizationStatus = ABAddressBookGetAuthorizationStatus()
    
    var addressBookRef: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue() as ABAddressBookRef
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func contactsButton(sender: AnyObject) {
        switch authorizationStatus {
        case .Denied, .Restricted:
            print("Denied")
            displayCantAddContactAlert()
        case .Authorized:
            print("Authorized")
            displayContacts()
        case .NotDetermined:
            print("Not Determined")
            promptForAddressBookRequestAccess()
        }
    }
    
    @IBAction func sendSMSButton(sender: AnyObject) {
        SMS().sendSMS(numberLabel.text!, message: messageField.text!)
        messageField.text = ""
    }
    
    
//    ----- Address book -----
    
    func promptForAddressBookRequestAccess() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Just denied")
                    self.displayCantAddContactAlert()
                } else {
                    print("Just authorized")
                }
            }
        }
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func displayCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
            message: "You must give the app permission to add the contact first.",
            preferredStyle: .Alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func displayContacts() {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        picker.displayedProperties = [NSNumber(int: kABPersonPhoneProperty), NSNumber(int: kABPersonFirstNameProperty)]
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecordRef, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        let multiValue: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(multiValue, identifier)
        let number = ABMultiValueCopyValueAtIndex(multiValue, index).takeRetainedValue() as! String
        numberLabel.text = number
    }
    
    
//    ---- Keyboard ----
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}

