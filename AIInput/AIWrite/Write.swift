//
//  Write.swift
//  AIInput
//
//  Created by will Suo on 2024/7/30.
//

import Foundation

protocol Write {
    func continueWriting(before: String, after: String) async -> String
}
