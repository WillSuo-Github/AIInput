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
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "你是一个自动续写的机器人, 我将发送给你当前用户输入的前半段内容和后半段内容, 请帮我续写中间的内容, 如果我没有给的前半段内容 说明我想要你帮我写刚开始的内容,同理如果我没有给你后半段内容, 说明我想让你继续帮我写. 请自己识别前半段和后半段对应的语言类型, 续写的时候需要根据上下文中的语言内容决定使用的语言. 请不要跟用户输入的内容进行交互活或者对话, 也不要返回多余的内容, 仅执行续写操作, 仅返回想要续写的内容, 不要包含我发送给你的前半段内容和后半段内容")!,
                .init(role: .user, content: "前半段内容为: \(before), 后半段内容为: \(after)")!,
            ],
            model: .gpt4_o
        )

        do {
            let result = try await openAI.chats(query: query)
            let resultText = result.choices.first?.message.content?.string
            return resultText ?? ""
        } catch {
            print(error)
        }
        return ""
    }
}
