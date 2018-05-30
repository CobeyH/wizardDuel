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
import FirebaseDatabase

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        FirebaseApp.configure()
        
        
        let login = loginInfo()

        Auth.auth().signIn(withEmail: login.username, password: login.password) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("login Successful")
                let myDataBase = Database.database().reference()
        }
        
    }
        
        
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    }
}

