//
//  AppDelegate.swift
//  AIInput
//
//  Created by will Suo on 2024/7/23.
//

import Cocoa
import SnapKit
import ApplicationServices
import Carbon

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    var monitor: Any?
    private var service = PermissionsService()
    
    private lazy var mainPanel: MainPanel = {
        let result = MainPanel()
        return result
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let button = NSButton(title: "test", target: self, action: #selector(test))
        window.contentView?.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: { event in
            self.handleKeyDownEvent(event)
        })
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // 移除监听器
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    func handleKeyDownEvent(_ event: NSEvent) {
        // 处理键盘事件
        let insertPosition = getCaretPosition2()
        guard let insertPosition = insertPosition, insertPosition != .zero else {
            print("No caret position found.")
            return
        }
        
        if event.keyCode == kVK_DownArrow || event.keyCode == kVK_UpArrow || event.keyCode == kVK_LeftArrow || event.keyCode == kVK_RightArrow {
            mainPanel.closeWindow()
        } else {
            mainPanel.show(on: insertPosition)
        }
    }
    
    @objc func test() {
        PermissionsService.shared.requestAccessibilityAccess()
    }
    
    func getFocusedUIElement() -> String? {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if let element = focusedElement {
            var value: AnyObject?
            AXUIElementCopyAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, &value)
            return value as? String
        }
        return nil
    }
    
    
    func getCaretPosition() -> CGPoint? {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        let appElement = AXUIElementCreateApplication(focusedApp.processIdentifier)
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result == .success, let focusedElement = focusedElement {
            var insertionPoint: CFTypeRef?
            let insertionPointResult = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXInsertionPointLineNumberAttribute as CFString, &insertionPoint)
            
            if insertionPointResult == .success, let _ = insertionPoint {
                var boundsValue: CFTypeRef?
                let boundsResult = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXFrameAttribute as CFString, &boundsValue)
                
                if boundsResult == .success {
                    var bounds = CGRect()
                    AXValueGetValue(boundsValue as! AXValue, .cgRect, &bounds)
                    
                    let screenFrame = NSScreen.screens.first?.frame ?? .zero
                    let caretPosition = CGPoint(x: bounds.origin.x, y: screenFrame.height - bounds.origin.y - bounds.height)
                    return caretPosition
                }
            }
        }
        return nil
    }
    
    func getCaretPosition2() -> CGPoint? {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        let appElement = AXUIElementCreateApplication(focusedApp.processIdentifier)
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if result == .success {
            var selectedRangeValue: CFTypeRef?
            let selectedRangeResult = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)

            if selectedRangeResult == .success {
                var selectedRange = CFRange()
                AXValueGetValue(selectedRangeValue as! AXValue, .cfRange, &selectedRange)
                print("selection range: \(selectedRange)")
                
                // Create a range for the exact position of the caret at the end of the current selection
                var caretRange = CFRange(location: selectedRange.location + selectedRange.length, length: 0)

                var boundsValue: CFTypeRef?
                let boundsResult = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, AXValueCreate(.cfRange, &caretRange)!, &boundsValue)

                if boundsResult == .success {
                    var bounds = CGRect()
                    AXValueGetValue(boundsValue as! AXValue, .cgRect, &bounds)

                    let screenFrame = NSScreen.screens.first?.frame ?? .zero
                    let caretPosition = CGPoint(x: bounds.origin.x, y: screenFrame.height - bounds.origin.y - bounds.height)
                    print("Caret position: \(insertPosition)")
                    return caretPosition
                }
            }
        }
        return nil
    }
    
    func getCaretPosition3() -> CGPoint? {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else {
            print("No focused application.")
            return nil
        }
        
        let appElement = AXUIElementCreateApplication(focusedApp.processIdentifier)
        var focusedElement: CFTypeRef?
        AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if let focusedElement = focusedElement  {
            var selectedTextRangeValue: CFTypeRef?
            AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedTextRangeValue)
            
            if let selectedTextRangeValue = selectedTextRangeValue {
                var selectedTextRange = CFRange()
                AXValueGetValue(selectedTextRangeValue as! AXValue, .cfRange, &selectedTextRange)
                
                // Using just the location as the cursor position since there is no selection.
                var cursorRange = CFRange(location: selectedTextRange.location, length: 0)
                var boundsValue: CFTypeRef?
                let boundsResult = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, AXValueCreate(.cfRange, &cursorRange)!, &boundsValue)
                
                if let boundsValue = boundsValue {
                    var bounds = CGRect.zero
                    AXValueGetValue(boundsValue as! AXValue, .cgRect, &bounds)
                    
                    let screenFrame = NSScreen.screens.first?.frame ?? .zero
                    let caretPosition = CGPoint(x: bounds.origin.x, y: screenFrame.height - bounds.origin.y - bounds.height)
                    print("Caret position: \(caretPosition)")
                    return caretPosition
                } else {
                    print("Failed to get bounds for the cursor range.")
                }
            } else {
                print("Failed to get cursor range.")
            }
        } else {
            print("Failed to get focused element.")
        }
        return nil
    }
}
