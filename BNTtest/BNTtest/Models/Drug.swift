//
//  Trouble.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

struct Drug: Codable {
    let id: Int?
    var imageURL: String?
    var categories: Category?
    let name, description, documentation: String?

    
    enum CodingKeys: String, CodingKey {
        case imageURL = "image"
        case id, name, description, documentation, categories
    }
}
