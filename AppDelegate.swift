//
//  AppDelegate.swift
//  fancontrol
//
//  Created by Julius Park on 4/23/18.
//  Copyright © 2018 Julius Park. All rights reserved.
//

import Cocoa

var AssociatedObjectHandle: UInt8 = 0
extension NSSlider {
    var fanId:String {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    @objc func sliderChanged(sender: NSSlider) {
        let sliderValue = sender.integerValue
        let curId = sender.fanId
        do{
            try SMCKit.fanSetMinSpeed(Int(curId)!, speed:Int(sliderValue))
        }
        catch {print("Error info: \(error)")}
        
        print(sliderValue)
    }
    func constructMenu() {
        let menu = NSMenu()
        
        do{
            try SMCKit.open()
            let fans=try SMCKit.allFans()
            for n in fans{
                let menuItem = NSMenuItem()
                menu.addItem(NSMenuItem(title: "Fan "+String(n.id), action: nil, keyEquivalent: ""))
                let fanSlider = NSSlider()
                fanSlider.setFrameSize(NSSize(width: 160, height: 16))
                fanSlider.minValue = Double(n.minSpeed)
                fanSlider.maxValue = Double(n.maxSpeed)
                fanSlider.fanId=String(n.id)
                fanSlider.target=self
                fanSlider.action=#selector(sliderChanged)
                menuItem.title = "Fan "+String(n.id)
                menuItem.view = fanSlider
                menu.addItem(menuItem)
            }
        }
        catch{
            print("Error info: \(error)")
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FanControl", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        menu.addItem(NSMenuItem())
        statusItem.menu = menu
    }


}

