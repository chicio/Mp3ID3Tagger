//
//  AppDelegate.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 30.03.18.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBAction func showHelp(_ sender: Any?) {
        if let mySite = URL(string: "https://www.fabrizioduroni.it") {
            NSWorkspace.shared.open(mySite)
        }
    }
}
