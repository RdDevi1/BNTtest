//
//  Constants.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 18.01.2024.
//

import Foundation

enum Constants {
    static let baseURL = "http://shans.d2.i-partner.ru"
    enum APIMethods: String {
        case item = "/api/ppp/item/"
        case index = "/api/ppp/index/"
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
