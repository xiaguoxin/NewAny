//
//  FinderSync.swift
//  NewAnyFinder
//
//  Created by 杨钺 on 2019/4/25.
//  Copyright © 2019 ilime. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    private let d = UserDefaults.standard
    let NewAnyFolderURL = URL(fileURLWithPath: "/Users/Shared/NewAny")
    
    override init() {
        super.init()
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [self.NewAnyFolderURL]
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
        let files = d.array(forKey: "NAFileList") as! [[String : String]]
        
        for file in files {
            menu.addItem(withTitle: file["name"]!, action: #selector(createFile(_:)), keyEquivalent: "")
        }
        
        return menu
    }
    
    @objc private func createFile(_ sender: AnyObject?) {
        
    }
}
