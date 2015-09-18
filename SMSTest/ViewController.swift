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
    
    let authorizationStatus = ABAddressBookGetAuthorizationStatus()
    
    var addressBookRef: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue() as ABAddressBookRef
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        picker.displayedProperties = [NSNumber(int: kABPersonPhoneProperty)]
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecordRef, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        let multiValue: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(multiValue, identifier)
        let number = ABMultiValueCopyValueAtIndex(multiValue, index).takeRetainedValue() as! String
        numberLabel.text = number
    }

    
    @IBAction func sendSMSButton(sender: AnyObject) {
        SMS().sendSMS(numberLabel.text!, message: messageField.text!)
        messageField.text = ""
    }
    
}

