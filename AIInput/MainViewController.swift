//
//  MainViewController.swift
//  AIInput
//
//  Created by will Suo on 2024/7/30.
//

import Foundation
import Cocoa

final class MainViewController: NSViewController {
    
    private lazy var textView: NSTextView = {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]  // Make sure it resizes with the scroll view
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.lineBreakMode = .byWordWrapping
        return textView
    }()
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.documentView = textView
        return scrollView
    }()
    
    override func loadView() {
        view = BaseView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UI
extension MainViewController {
    private func setupUI() {
        guard let view = view as? BaseView else { return }
        view.backgroundColor = .windowBackgroundColor
        
        view.snp.makeConstraints { make in
            make.width.equalTo(500)
            make.height.equalTo(200)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func updateText(string: String) {
        textView.string = string
    }
}
