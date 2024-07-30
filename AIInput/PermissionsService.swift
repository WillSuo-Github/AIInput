//
//  PermissionsService.swift
//  AIInput
//
//  Created by will Suo on 2024/7/23.
//

import Foundation
import Cocoa

final class PermissionsService: ObservableObject {
    @Published var isTrusted: Bool = AXIsProcessTrusted()
    
    static var shared: PermissionsService = .init()
    
    func accessibilityIsTrustedRefresh(onTrusted: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // print("isTrusted value refresh") // each 1~ sec
            self.isTrusted = AXIsProcessTrusted()
            
            if self.isTrusted {
                onTrusted()
            } else {
                self.accessibilityIsTrustedRefresh(onTrusted: onTrusted)
            }
        }
    }
    
    func requestAccessibilityAccess() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let _ = AXIsProcessTrustedWithOptions(options)
    }
}
