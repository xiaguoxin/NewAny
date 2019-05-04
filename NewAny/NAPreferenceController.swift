//
//  NAPreferenceController.swift
//  NewAny
//
//  Created by 杨钺 on 2019/4/26.
//  Copyright © 2019 ilime. All rights reserved.
//

import os.log
import Cocoa

class NAPreferenceController: NSViewController, NSTableViewDataSource {
    
    static let log = OSLog(subsystem: "org.ilime.NewAny", category: "NAPreferenceController")
    private let NewAnyFolderURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Containers/org.ilime.NewAny.NewAnyFinder/Data/NewAnyFolder")
    @IBOutlet weak var addFileTextField: NSTextField!
    @IBOutlet weak var filesTable: NSTableView!
    
    func initFileList() {
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            let files = d.array(forKey: "NAFileList")
            if files == nil {
                d.set([], forKey: "NAFileList")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filesTable.delegate = self
        filesTable.dataSource = self
        
        initFileList()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            return d.array(forKey: "NAFileList")?.count ?? 0
        }
        
        return 0
    }
    
    @IBAction func addFile(_ sender: NSButton) {
        let filename = addFileTextField.stringValue
        if (filename.isEmpty) {
            return
        }
        
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            var files = d.array(forKey: "NAFileList")!
            files.append(["name": filename, "exist": "N"])
            d.set(files, forKey: "NAFileList")
            
            reloadFileList()
            
            addFileTextField.stringValue = ""
        }
    }
    
    @IBAction func importFile(_ sender: NSButton) {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                do {
                    try FileManager.default.copyItem(at: url, to: NewAnyFolderURL.appendingPathComponent(url.lastPathComponent))
                    
                    if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
                        var files = d.array(forKey: "NAFileList")!
                        files.append(["name": url.lastPathComponent, "exist": "Y"])
                        d.set(files, forKey: "NAFileList")
                        
                        reloadFileList()
                    }
                } catch let error {
                    let message = "Error occuring in importFile(): \(error)"
                    os_log("%@", log: NAPreferenceController.log, type: .error, message)
                }
            }
        }
    }
    
    func reloadFileList() {
        filesTable.reloadData()
    }
}

extension NAPreferenceController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            let files = d.array(forKey: "NAFileList")
            
            guard let file = files?[row] as? [String: String] else {
                return nil
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCellID"), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = file["name"]!
                return cell
            }
        }
        
        return nil
    }
    
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(deleteFile(_:)), keyEquivalent: ""))
        filesTable.menu = menu
    }
    
    @objc private func deleteFile(_ sender: AnyObject) {
        guard !filesTable.selectedRowIndexes.isEmpty else {
            return
        }
        
        if let d = UserDefaults(suiteName: "group.org.ilime.NewAny.SharedData") {
            var files = d.array(forKey: "NAFileList") as! [[String: String]]
            filesTable
                .selectedRowIndexes
                .sorted(by: >)
                .forEach { index in
                    if files[index]["exist"] == "Y" {
                        let filename = files[index]["name"]!
                        
                        do {
                            try FileManager.default.removeItem(at: NewAnyFolderURL.appendingPathComponent(filename))
                        } catch let error {
                            let message = "Error occuring in deleteFile(): \(error)"
                            os_log("%@", log: NAPreferenceController.log, type: .error, message)
                        }
                    }
                    
                    files.remove(at: index)
            }
            d.set(files, forKey: "NAFileList")
            
            reloadFileList()
        }
    }
}
