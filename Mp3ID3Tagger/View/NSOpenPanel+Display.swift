//
//  NSOpenPanel+Display.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 13.04.18.
//

import Foundation
import Cocoa

extension NSOpenPanel {
    static func display(in window: NSWindow, fileTypes: [String], title: String, onComplete: @escaping (NSOpenPanel, NSApplication.ModalResponse) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.title = title
        openPanel.allowedFileTypes = fileTypes
        openPanel.beginSheetModal(for: window) { response in
            onComplete(openPanel, response)
            openPanel.close()
        }
    }
}
