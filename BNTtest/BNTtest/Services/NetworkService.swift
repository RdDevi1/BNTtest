//
//  NetworkService.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 15.01.2024.
//

import Foundation

protocol NetworkServiceProtocol {
    func getItemBy(_ id: Int, completion: @escaping (Result<Drug, NetworkError>) -> ())
    func downloadImageFor(drug: Drug, completion: @escaping (Result<URL, NetworkError>) -> ())
    func downloadCategoryIconFor(drug: Drug, completion: @escaping (Result<URL, NetworkError>) -> ())
    func getItemsOn(query: String,
                    startingFrom offset: Int,
                    amount limit: Int,
                    completion: @escaping (Result<[Drug], NetworkError>) -> ())
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case downloadError
    case decodingError
}

final class NetworkService: NetworkServiceProtocol {
    private let networkQueue = DispatchQueue(label: "networkQueue",
                                             qos: .default,
                                             attributes: .concurrent)
    private let urlSession = URLSession.shared
    
    func getItemBy(_ id: Int, completion: @escaping (Result<Drug, NetworkError>) -> ()) {
        networkQueue.async { [weak self] in
            guard let self = self else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            guard let url = URL(string: Constants.baseURL + Constants.APIMethods.item.rawValue) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            let parameters = ["id": "\(id)"]
            self.performRequest(url: url, parameters: parameters, completion: completion)
        }
    }

    func getItemsOn(query: String = "",
                    startingFrom offset: Int = 0,
                    amount limit: Int = 10,
                    completion: @escaping (Result<[Drug], NetworkError>) -> ()) {
        
        networkQueue.async { [weak self] in
            guard let self = self else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            guard let url = URL(string: Constants.baseURL + Constants.APIMethods.index.rawValue) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            let parameters = [
                "offset": "\(offset)",
                "limit": "\(limit)",
                "search": "\(query)"
            ]

            self.performRequest(url: url, parameters: parameters, completion: completion)
        }
    }

    private func downloadImage(at url: URL, completion: @escaping (Result<URL, NetworkError>) -> ()) {
        self.urlSession.downloadTask(with: url) { tempURL, response, error in
            guard error == nil, let tempURL = tempURL else {
                completion(.failure(NetworkError.downloadError))
                return
            }
            
            guard let newImageURL = URLComponents(string: FileManager.default.imagesDir.absoluteString + url.lastPathComponent)?.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            if FileManager.default.fileExists(atPath: newImageURL.path) {
                completion(.success(newImageURL))
            } else {
                do {
                    try FileManager.default.moveItem(at: tempURL, to: newImageURL)
                    completion(.success(newImageURL))
                } catch {
                    completion(.failure(NetworkError.downloadError))
                    print("Can not move image at \(tempURL) to \(newImageURL)")
                }
            }
        }.resume()
    }

    func downloadImageFor(drug: Drug, completion: @escaping (Result<URL, NetworkError>) -> ()) {
        networkQueue.async { [weak self] in
            guard let self = self,
                  let imagePath = drug.imageURL,
                  let imageURL = URLComponents(string: Constants.baseURL + imagePath)?.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            self.downloadImage(at: imageURL, completion: completion)
        }
    }

    func downloadCategoryIconFor(drug: Drug, completion: @escaping (Result<URL, NetworkError>) -> ()) {
        networkQueue.async { [weak self] in
            guard let self = self,
                  let imagePath = drug.categories?.icon,
                  let imageURL = URLComponents(string: Constants.baseURL + imagePath)?.url else {
                completion(.failure(NetworkError.invalidURL))
                return
            }

            self.downloadImage(at: imageURL, completion: completion)
        }
    }

    private func validateResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Bool {
        guard error == nil else {
            print(error!.localizedDescription)
            return false
        }

        if let response = response as? HTTPURLResponse,
            response.statusCode < 200 || response.statusCode > 299
        {
            print("Bad response code")
            return false
        }

        guard data != nil else {
            print("Response does not contain data")
            return false
        }
        return true
    }

    private func performRequest<T: Decodable>(url: URL, parameters: [String: String], completion: @escaping (Result<T, NetworkError>) -> ()) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let requestURL = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = HttpMethod.get.rawValue

        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(NetworkError.invalidURL))
                print("Error in network request: \(error.localizedDescription)")
                return
            }

            guard self.validateResponse(data, response, error) else {
                completion(.failure(NetworkError.invalidResponse))
                print("Invalid network response")
                return
            }

            do {
                let result: T = try JSONDecoder().decode(T.self, from: data!)
                completion(.success(result))
            } catch {
                completion(.failure(NetworkError.decodingError))
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

extension NetworkService: ServiceProtocol {
    var description: String {
        return "NetworkService"
    }
}
