//
//  MainPanel.swift
//  AIInput
//
//  Created by will Suo on 2024/7/30.
//

import Cocoa
import KeyboardShortcuts

class MainPanel: NSPanel {
    private(set) lazy var mainViewController: MainViewController = {
        let result = MainViewController()
        return result
    }()
    
    init() {
        super.init(contentRect: .zero, styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel, .borderless], backing: .buffered, defer: false)

        self.setFrameAutosaveName("MainPanel")
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.isFloatingPanel = true
        self.isRestorable = true
        self.level = .popUpMenu
        self.collectionBehavior.insert(.fullScreenAuxiliary)
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        setupContentView()
        setupUI()
        setupObserver()
        registerHotKey()
    }
    
    override var contentView: NSView? {
        didSet {
            setupContentView()
        }
    }
    
    override var contentViewController: NSViewController? {
        didSet {
            setupContentView()
        }
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    private func setupContentView() {
        contentView?.wantsLayer = true
        contentView?.layer?.frame = contentView?.frame ?? .zero
    }
}

// MARK: - UI
extension MainPanel {
    private func setupUI() {
        contentViewController = mainViewController
    }
    
    @MainActor
    func show(on point: NSPoint?, text: String) {
        mainViewController.updateText(string: text)
        if let point = point {
            let realPoint = NSPoint(x: point.x, y: point.y + 44)
            setFrameOrigin(realPoint)
        } else {
            center()
        }
        makeKeyAndOrderFront(nil)
    }
    
    func closeWindow() {
        close()
    }
}

// MARK: - Action
extension MainPanel {
    private func accept() {
        insertTextAtCursorPosition(text: mainViewController.currentText)
        closeWindow()
    }
    
    func insertTextAtCursorPosition(text: String) {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return
        }

        let pid = frontmostApp.processIdentifier
        let axApp = AXUIElementCreateApplication(pid)

        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if result == .success, let focusedElement = focusedElement {
            let axFocusedElement = focusedElement as! AXUIElement

            var currentValue: CFTypeRef?
            let copyResult = AXUIElementCopyAttributeValue(axFocusedElement, kAXValueAttribute as CFString, &currentValue)

            if copyResult == .success, let currentValue = currentValue as? String {
                // 获取当前光标位置
                var selectedTextRange: CFTypeRef?
                let rangeResult = AXUIElementCopyAttributeValue(axFocusedElement, kAXSelectedTextRangeAttribute as CFString, &selectedTextRange)

                if rangeResult == .success, let range = selectedTextRange {
                    var rangeStruct = CFRange()
                    AXValueGetValue(range as! AXValue, .cfRange, &rangeStruct)

                    // 构建插入后的文本
                    let beforeCursor = (currentValue as NSString).substring(to: rangeStruct.location)
                    let afterCursor = (currentValue as NSString).substring(from: rangeStruct.location)
//                    let newValue = beforeCursor + text + afterCursor
                    let newValue = text

                    // 设置新的文本值
                    AXUIElementSetAttributeValue(axFocusedElement, kAXValueAttribute as CFString, newValue as CFTypeRef)

                    // 移动光标到插入后的新位置
                    let newCursorPosition = rangeStruct.location + text.count
                    var newRange = CFRange(location: newCursorPosition, length: 0)
                    let newAXValue = AXValueCreate(.cfRange, &newRange)
                    AXUIElementSetAttributeValue(axFocusedElement, kAXSelectedTextRangeAttribute as CFString, newAXValue!)
                }
            }
        }
    }
}

// MARK: - Observer
extension MainPanel {
    private func setupObserver() {
        delegate = self
    }
}

// MARK: - Register
extension MainPanel {
    private func registerHotKey() {
        KeyboardShortcuts.onKeyDown(for: .main) { [weak self] in
            self?.show(on: nil, text: "")
        }
        
        KeyboardShortcuts.onKeyDown(for: .accept) { [weak self] in
            guard let self = self else { return }
            self.accept()
        }
    }
}

// MARK: - NSWindowDelegate
extension MainPanel: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        closeWindow()
    }
    
    func windowDidChangeOcclusionState(_ notification: Notification) {
        if occlusionState.contains(NSWindow.OcclusionState.visible) == false {
            closeWindow()
        }
    }
    
    func windowDidMove(_ notification: Notification) {
        saveWindowFrame()
    }
    
    private func saveWindowFrame() {
//        let frameString = NSStringFromRect(self.frame)
//        Defaults[\.MainPanelFrame] = frameString
    }
}


//extension DefaultsKeys {
//    var MainPanelFrame: DefaultsKey<String?> {
//        return .init("MainPanelFrame", defaultValue: nil)
//    }
//}


extension KeyboardShortcuts.Name {
    static let main = Self("Main", default: .init(.a, modifiers: [.command, .shift]))
    static let accept = Self("Accept", default: .init(.return, modifiers: [.command, .shift]))
}


