//
//  ParsingFunctions.swift
//  OnTheMap
//
//  Created by Petr Stenin on 24/03/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation

// Functions for extracting required data from serialized JSONs
extension ParseClient {
    
    // Send Request and retrieve Session ID & User ID
    func getSessionAndUserID(loginVC: LoginViewController, completionHandlerForLogin: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        if let userName = loginVC.loginTextField.text, let password = loginVC.passwordTextField.text {
            let urlForLoginWithUdacity = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/session", parameters: nil)
            let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.post, withURL: urlForLoginWithUdacity, httpHeaderFieldValue: ["Accept":"application/json", "Content-Type":"application/json"], httpBody: "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}", completionHandlerForTask: {(data, error) in
                if error == nil {
                    print("SUCCESS!!! ==got session ID & user ID==")
                    let postSession = data as! [String:AnyObject]
                    
                    // Set client shared instance's property: sessionID
                    let sessionInfo = postSession[ParseClient.UdacityResponseKeys.session] as! [String:AnyObject]
                    let sessionID = sessionInfo[ParseClient.UdacityResponseKeys.id] as! String
                    ParseClient.sharedInstance().sessionID = sessionID
                    
                    // Set client shared instance's property: userID
                    let accountInfo = postSession[ParseClient.UdacityResponseKeys.account] as! [String:AnyObject]
                    let userID = accountInfo[ParseClient.UdacityResponseKeys.key] as! String
                    ParseClient.sharedInstance().userID = userID
                    
                    // Launch completion handler with parms for successful option
                    completionHandlerForLogin(true, nil)
                    
                } else {
                    // Launch completion handler with parms for unsuccessful option
                    completionHandlerForLogin(false, error)
                }
            })
        }
    }
    
    func getInitialUserInfo(completionHandlerForGetIserInfo: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlForGetUserInfo = ParseClient.sharedInstance().makeURL(apiHost: ParseClient.Constants.UdacityApiHost, apiPath: ParseClient.Constants.UdacityApiPath, withExtension: "/users/\(ParseClient.sharedInstance().userID!)", parameters: nil)
        let _ = ParseClient.sharedInstance().taskForMethod(ParseClient.MethodTypes.get, withURL: urlForGetUserInfo, httpHeaderFieldValue: [:], httpBody: nil, completionHandlerForTask: {(data, error) in
            if error == nil {
                print("SUCCESS!!! ==got User Info==")
                let getUserData = data as! [String:AnyObject]
                
                // Set client shared instance's properties: user first & last names
                let userInfo = getUserData[ParseClient.UdacityUserData.user] as! [String:AnyObject]
                if let userFirstName = userInfo[ParseClient.UdacityUserData.firstName] as? String, let userLastName = userInfo[ParseClient.UdacityUserData.lastName] as? String {
                    ParseClient.sharedInstance().userFirstName = userFirstName
                    ParseClient.sharedInstance().userLastName = userLastName
                    completionHandlerForGetIserInfo(true, nil)
                } else {
                    completionHandlerForGetIserInfo(false, NSError(domain: "getInitialUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot retrieve user info: \(ParseClient.UdacityUserData.firstName), \(ParseClient.UdacityUserData.lastName)"]))
                }
            } else {
                completionHandlerForGetIserInfo(false, error)
            }
            
        })
    }
}
