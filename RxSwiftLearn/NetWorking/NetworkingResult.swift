//
//  NetworkingResult.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import Foundation

// Extension CodingUserInfoKey to custom key of userInfo to decode exactly
public extension CodingUserInfoKey {
    static let contentKey = CodingUserInfoKey(rawValue: "contentKey")
}

//Create struct NetWokingResult to decode data response for any contentKey
struct NetworkingResult<Content: Codable>: Decodable {
    // content property contain result decode
    let content: Content
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(intValue: Int) {
            return nil
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = 0
        }
    }
    
    init(from decoder: Decoder) throws {
        guard let contentKey = CodingUserInfoKey.contentKey,
              let keyUserInfor = decoder.userInfo[contentKey],
              let keyUserInforString = keyUserInfor as? String,
              let codingKeys = CodingKeys(stringValue: keyUserInforString) else {
            throw NetworkingError.invalidDecoderConfiguration
        }
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            content = try container.decode(Content.self, forKey: codingKeys)
        } catch {
            throw NetworkingError.invalidDecoderConfiguration
        }
    }
}
