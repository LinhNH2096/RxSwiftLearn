//
//  NetWorking.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import Foundation
import RxSwift

final class NetWorking {
    
    // MARK: - Endpoint
    enum EndPoint {
        static var baseURL: URL? = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/")
        
        case categories
        case items
        
        var url: URL? {
            switch self {
            case .categories:
                return EndPoint.baseURL?.appendingPathComponent("list.php")
            case .items:
                return EndPoint.baseURL?.appendingPathComponent("filter.php")
            }
        }
    }
    
    // MARK: - Singleton
    private static var shareNetworking: NetWorking = {
        return NetWorking()
    }()
    
    private init() {}
    
    static func share() -> NetWorking {
        return shareNetworking
    }
    
    // MARK: - Process method
    static func jsonDecode(contentKey: String) -> JSONDecoder {
        let decoder = JSONDecoder()
        guard let userInforContentKey = CodingUserInfoKey.contentKey else {
            return decoder
        }
        decoder.userInfo[userInforContentKey] = contentKey
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    // MARK: - Request
    // Request - GET
    func request<T: Codable>(url: URL?, query:[String: Any] = [:], contentKey: String = "") -> Observable<T> {
        do {
            guard let URL = url,
                  var components = URLComponents(url: URL, resolvingAgainstBaseURL: true) else {
                throw NetworkingError.invalidURL(url?.absoluteString ?? "A/N")
            }
            components.queryItems =
                try query.compactMap({ key, values in
                    guard let value = values as? CustomStringConvertible else {
                        throw NetworkingError.invalidParameter("Invalid Param: \(key): \(values)")
                    }
                    return URLQueryItem(name: key, value: value.description)
                })
            guard let finalURL = components.url else {
                throw NetworkingError.invalidURL(url?.absoluteString ?? "A/N")
            }
            let request = URLRequest(url: finalURL)
            return URLSession.shared.rx
                .response(request: request)
                .map { (response, data) -> T in
                    if contentKey != "" {
                        let decoder = NetWorking.jsonDecode(contentKey: contentKey)
                        let envelope = try decoder.decode(NetworkingResult<T>.self, from: data)
                        return envelope.content
                    } else {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        return result
                    }
                }
        } catch {
            print(error.localizedDescription)
            return Observable.empty()
        }
    }
    
    // MARK: - Bussiness
    func getCategory(kind: String) -> Observable<[CocktailCategory]> {
        let query: [String: Any] = [kind: "list"]
        let url = EndPoint.categories.url
        
        let result: Observable<[CocktailCategory]> = request(url: url, query: query, contentKey: "drinks")
        return result
            .catchAndReturn([])
            .share(replay: 1, scope: .forever)
    }
    
    func getDrinks(kind: String, value: String) -> Observable<[Drink]> {
        let query: [String: Any] = [kind: value]
        let url = EndPoint.items.url
        
        let result: Observable<[Drink]> = request(url: url, query: query, contentKey: "drinks")
        return result
            .catchAndReturn([])
            .share(replay: 1, scope: .forever)
    }
}
