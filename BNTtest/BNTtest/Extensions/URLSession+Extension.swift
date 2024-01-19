//
//  URLSession+Extension.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 19.01.2024.
//

import Foundation

extension URLSession {
    
    private enum URLSessionError: Error {
        case codeError, decodeError
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                    return
                }
                
                if
                    let response = response as? HTTPURLResponse,
                    response.statusCode < 200 || response.statusCode > 299
                {
                    completion(.failure(URLSessionError.codeError))
                    print("ERROR --> bad code responce: \(response.statusCode) for model: \(T.self)" )
                    return
                }
                
                guard let data else { return }
                
                do {
                    let jsonData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(jsonData))
                } catch {
                    completion(.failure(URLSessionError.decodeError))
                    print("ERROR --> data decode for \(T.self) decodeError")
                }
            }
        }
        return task
    }
}
