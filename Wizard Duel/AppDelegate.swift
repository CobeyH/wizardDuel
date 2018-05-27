//
//  AppDelegate.swift
//  Freegraveyard2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//


import Cocoa
import FirebaseAuth
import FirebaseCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //TODO: Log in the user

        FirebaseApp.configure()

        Auth.auth().signIn(withEmail: "blah@gmail.com", password: "blah") { (user, error) in
            if error != nil {
                print("Error logging in")
            } else {
                print("login Successful")
                
            }
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
