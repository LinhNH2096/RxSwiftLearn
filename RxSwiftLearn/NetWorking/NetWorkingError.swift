//
//  NetWorkingError.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import Foundation

// Enum define Networking Error
enum NetworkingError: Error {
    case requestProcessError(String)
    case invalidURL(String)
    case invalidParameter(String)
    case invalidJSON(String)
    case invalidDecoderConfiguration
}
