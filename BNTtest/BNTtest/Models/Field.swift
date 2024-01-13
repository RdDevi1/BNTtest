//
//  Fields.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

struct Field: Codable {
    var type: String
    var name: String
    var value: String
    var image: String
    var flags: Flag
    var show: Int
    var group: Int
}
