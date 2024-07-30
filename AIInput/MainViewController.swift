//
//  MainViewController.swift
//  AIInput
//
//  Created by will Suo on 2024/7/30.
//

import Foundation
import Cocoa

final class MainViewController: NSViewController {
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UI
extension MainViewController {
    private func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue.cgColor
        
        view.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
    }
}
