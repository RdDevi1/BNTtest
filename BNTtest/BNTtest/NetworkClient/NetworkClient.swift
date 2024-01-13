//
//  NetworkClient.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int, Data?)
    case urlRequestError(Error)
    case urlSessionError
    case customError(String)
    case decode
}
