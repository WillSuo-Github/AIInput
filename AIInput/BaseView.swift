//
//  BaseView.swift
//  Tamer-Mac
//
//  Created by Liyanke on 8/12/2023.
//

import Cocoa

class BaseView: NSView {
    typealias MouseEventBlock = (NSEvent) -> Bool
    
    var backgroundColor: NSColor? {
        didSet {
            wantsLayer = true
            needsDisplay = true
        }
    }
    
    var borderColor: NSColor? {
        didSet {
            wantsLayer = true
            needsDisplay = true
        }
    }
    
    var mouseDownBlock: MouseEventBlock?
    
    override func updateLayer() {
        super.updateLayer()
        
        if let backgroundColor = backgroundColor {
            layer?.backgroundColor = backgroundColor.cgColor
        }
        
        if let borderColor = borderColor {
            layer?.borderColor = borderColor.cgColor
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if let mouseDownBlock = mouseDownBlock, mouseDownBlock(event) {
            return
        } else {
            super.mouseDown(with: event)
        }
    }
}
