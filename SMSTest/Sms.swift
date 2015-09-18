//
//  Sms.swift
//  SMSTest
//
//  Created by Adam Rais on 16/09/2015.
//  Copyright © 2015 Adamgoodapp. All rights reserved.
//

import Foundation
import Alamofire

class SMS {
    
    func sendSMS(number:String, message:String) {
        Alamofire.request(.GET, "https://obscure-gorge-5606.herokuapp.com/sms", parameters: ["number": number, "message": message])
            .response { request, response, data, error in
                
        }
    }
    
}