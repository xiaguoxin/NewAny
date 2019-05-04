//
//  NAPreferenceController.swift
//  NewAny
//
//  Created by 杨钺 on 2019/4/26.
//  Copyright © 2019 ilime. All rights reserved.
//

import Cocoa

class NAPreferenceController: NSViewController, NSTableViewDataSource {
    
    private let d = UserDefaults.standard
    
    @IBOutlet weak var addFileTextField: NSTextField!
    @IBOutlet weak var filesTable: NSTableView!
    
    func initFileList() {
        let files = d.array(forKey: "NAFileList")
        if files == nil {
            d.set([], forKey: "NAFileList")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filesTable.delegate = self
        filesTable.dataSource = self
        initFileList()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return d.array(forKey: "NAFileList")?.count ?? 0
    }
    
    @IBAction func addFile(_ sender: NSButton) {
        let filename = addFileTextField.stringValue
        var files = d.array(forKey: "NAFileList")!
        
        files.append(["name": filename])
        d.set(files, forKey: "NAFileList")
        
        reloadFileList()
        
        addFileTextField.stringValue = ""
    }
    
    @IBAction func importFile(_ sender: NSButton) {
    }
    
    func reloadFileList() {
        filesTable.reloadData()
    }
}

extension NAPreferenceController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let files = d.array(forKey: "NAFileList")
        
        guard let file = files?[row] as? [String: String] else {
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCellID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = file["name"]!
            return cell
        }
        
        return nil
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(deleteFile(_:)), keyEquivalent: ""))
        filesTable.menu = menu
    }
    
    @objc private func deleteFile(_ sender: AnyObject) {
        guard filesTable.clickedRow >= 0 else { return }

        var files = d.array(forKey: "NAFileList")!
        files.remove(at: filesTable.clickedRow)
        d.set(files, forKey: "NAFileList")
        
        reloadFileList()
    }
}
