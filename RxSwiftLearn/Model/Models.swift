//
//  CocktailCategory.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import Foundation

// Generic Category Result
struct CategoryResult<T: Codable>: Codable {
    var items: [T]
    
    enum CodingKeys: String, CodingKey {
        case items = "drinks"
    }
}

// Cocktail Category
struct CocktailCategory: Codable {
    var nameCategory: String
    var items = [Drink]()
    
    enum CodingKeys: String, CodingKey {
        case nameCategory = "strCategory"
    }
}

// Drink
struct Drink: Codable {
    let name: String
    let imageURL: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "strDrink"
        case imageURL = "strDrinkThumb"
        case id = "idDrink"
    }
}
