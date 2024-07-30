//
//  Chatgpt.swift
//  AIInput
//
//  Created by will Suo on 2024/7/30.
//

import Foundation
import OpenAPIKit
import OpenAI

final class Chatgpt {
    static let shared = Chatgpt()
}

extension Chatgpt: Write {
    func continueWriting(before: String, after: String) async -> String {
        let key = ""
        let openAI = OpenAI(apiToken: key)
        let query = ChatQuery(messages: [.init(role: .user, content: "who are you")!], model: .gpt3_5Turbo)

        do {
            let result = try await openAI.chats(query: query)
            let resultText = result.choices.first?.message.content?.string
            print("chatgpt result", resultText)
            return resultText ?? ""
        } catch {
            print(error)
        }
        return ""
    }
}
