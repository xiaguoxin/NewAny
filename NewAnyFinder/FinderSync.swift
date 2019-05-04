//
//  FinderSync.swift
//  NewAnyFinder
//
//  Created by 杨钺 on 2019/4/25.
//  Copyright © 2019 ilime. All rights reserved.
//

import os.log
import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    static let log = OSLog(subsystem: "org.ilime.NewAny.NewAnyFinder", category: "FinderSync")
    private let NewAnyFolderURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("NewAnyFolder")
    
    override init() {
        super.init()
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [NewAnyFolderURL]
        
        checkNewAnyFolder()
    }
    
    func checkNewAnyFolder() {
        if !FileManager.default.fileExists(atPath: NewAnyFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: NewAnyFolderURL, withIntermediateDirectories: false, attributes: nil)
            } catch let error {
                let message = "Error occuring in checkNewAnyFolder(): \(error)"
                os_log("%@", log: FinderSync.log, type: .error, message)
            }
        }
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "NewAny"
    }
    
    override var toolbarItemToolTip: String {
        return "NewAny: Finder sync extension let you create any files as you wish."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: NSImage.addTemplateName)!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "NewAny")
        
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            let files = d.array(forKey: "NAFileList") as! [[String : String]]
            
            for file in files {
                menu.addItem(withTitle: file["name"]!, action: #selector(createFile(_:)), keyEquivalent: "")
            }
        }
        
        return menu
    }
    
    @objc private func createFile(_ item: NSMenuItem) {
        let filename = item.title
        
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            var files = d.array(forKey: "NAFileList") as! [[String : String]]
            var selectedFile: [String: String] = [:]
            
            for file in files {
                if file["name"] == filename {
                    selectedFile = file
                    break
                }
            }
            
            if !selectedFile.isEmpty {
                if let to = FIFinderSyncController.default().targetedURL()?.appendingPathComponent(filename) {
                    do {
                        let at = NewAnyFolderURL.appendingPathComponent(filename)
                        
                        if selectedFile["exist"] == "N" {
                            try "".write(to: at, atomically: false, encoding: .utf8)
                            try FileManager.default.copyItem(at: at, to: to)
                            
                            for i in 0..<files.count {
                                if files[i]["name"] == filename {
                                    files[i]["exist"] = "Y"
                                }
                            }
                            
                            d.set(files, forKey: "NAFileList")
                        } else if selectedFile["exist"] == "Y" {
                            try FileManager.default.copyItem(at: at, to: to)
                        }
                    } catch let error {
                        let message = "Error occuring in createFile(): \(error)"
                        os_log("%@", log: FinderSync.log, type: .error, message)
                    }
                }
            }
        }
    }
}
