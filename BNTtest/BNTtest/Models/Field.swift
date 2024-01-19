//
//  Fields.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

struct Field: Codable {
    let typesID: Int?
    let type: TypeEnum?
    let name, value: String?
    let image: String?
    let flags: Flag?
    let show, group: Int?

    enum CodingKeys: String, CodingKey {
        case typesID = "types_id"
        case type, name, value, image, flags, show, group
    }
}

enum TypeEnum: String, Codable {
    case image = "image"
    case list = "list"
    case text = "text"
}

