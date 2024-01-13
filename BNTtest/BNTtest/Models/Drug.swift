//
//  Trouble.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

struct Drug: Codable {
    var id: Int
    var image: String
    var categories: Category
    var name: String
    var description: String
    var documentation: String
    var fields: [Field]?
}
