//
//  ServiceProtocols.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 17.01.2024.
//

import Foundation

enum Service {
    case router, moduleBuilder, networkService
}

protocol ServiceProtocol: CustomStringConvertible {
    
}

protocol ServiceObtainableProtocol {
    var neededServices: [Service] {get}
    func getServices(_ services: [Service: ServiceProtocol])
}
