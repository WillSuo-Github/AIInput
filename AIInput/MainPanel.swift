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
}
