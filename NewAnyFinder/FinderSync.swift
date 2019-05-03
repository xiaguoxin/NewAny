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
        menu.addItem(withTitle: "Example Menu Item", action: #selector(sampleAction(_:)), keyEquivalent: "")
        return menu
    }
    
    @IBAction func sampleAction(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        let items = FIFinderSyncController.default().selectedItemURLs()
        
        let item = sender as! NSMenuItem
        NSLog("sampleAction: menu item: %@, target = %@, items = ", item.title as NSString, target!.path as NSString)
        for obj in items! {
            NSLog("    %@", obj.path as NSString)
        }
    }
}
