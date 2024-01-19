//
//  Flag.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

struct Flag: Codable {
    let html, noValue, noName, noImage: Int?
    let noWrap, noWrapName, system: Int?

    enum CodingKeys: String, CodingKey {
        case html
        case noValue = "no_value"
        case noName = "no_name"
        case noImage = "no_image"
        case noWrap = "no_wrap"
        case noWrapName = "no_wrap_name"
        case system
    }
}
