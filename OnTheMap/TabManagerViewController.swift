//
//  TabManagerViewController.swift
//  OnTheMap
//
//  Created by Petr Stenin on 25/03/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit

class TabManagerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    // Launch VC to add a new pin
    @IBAction func addNewPin(_ sender: UIBarButtonItem) {
        //let addNewPinViewController = storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.inputController) as! AddNewPinViewController
        let addNewPinNavigationViewController = storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.navigationInputController) as! UINavigationController
        self.present(addNewPinNavigationViewController, animated: true, completion: nil)
    }
    
    // Refresh button - common for Map and List
    @IBAction func refreshStudentLocations(_ sender: UIBarButtonItem) {
        ParseClient.sharedInstance().getAllStudentLocations(completionHandlerForGetAllStudentLocations: {(success, error) in
            if success {
                performUIUpdatesOnMain {
                    // Confirm the update with AlertView
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.success, message: "Database updated", actionTitle: ParseClient.ErrorStrings.dismiss)
                    
                    // Update the table ('list') view
                    ListViewController.sharedInstance().studentLocations = ParseClient.sharedInstance().studentLocations
                    ListViewController.sharedInstance().tableView.reloadData()
                    
                    // TODO: Refresh map view
                    MapViewController.sharedInstance().studentLocations = ParseClient.sharedInstance().studentLocations
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.description, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        ParseClient.sharedInstance().deleteSessionID(completionHandlerForDeleteSessionID: {(success, error) in
            if success {
                print("ID deleted")
                performUIUpdatesOnMain {
                    let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: ParseClient.StoryBoardIdentifiers.loginViewController)
                    self.present(loginViewController, animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: error?.description, actionTitle: ParseClient.ErrorStrings.dismiss)
                }
            }
        })
    }
}
