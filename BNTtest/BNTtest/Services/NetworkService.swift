//
//  NetworkService.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 15.01.2024.
//

import Foundation

protocol NetworkServiceProtocol {
    func getItemBy(_ id: Int, completion: @escaping (Result<Drug, Error>) -> ())
    func downloadImageFor(drug: Drug, completion: @escaping (Result<URL,Error>) -> ())
    func downloadCategoryIconFor(drug: Drug, completion: @escaping (Result<URL,Error>) -> ())
    func getItemsOn(query: String,
                    startingFrom offset: Int,
                    amount limit: Int,
                    completion: @escaping (Result<[Drug], Error>) -> ())
}


final class NetworkService: NetworkServiceProtocol {
    private let networkQueue = DispatchQueue(label: "networkQueue",
                                             qos: .default,
                                             attributes: .concurrent)
    private let urlSession = URLSession.shared
    
    
    func getItemBy(_ id: Int, completion: @escaping (Result<Drug, Error>) -> ()) {
        networkQueue.async {
            var urlComponents = URLComponents(string: Constants.baseURL + Constants.APIMethods.item.rawValue)!
            urlComponents.queryItems = [URLQueryItem(name: "id", value: "\(id)")]
            
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = HttpMethod.get.rawValue
            
            self.urlSession.dataTask(with: request) { [unowned self] data, response, error in
                guard validateResponse(data, response, error) else {
                    completion(.failure(error!))
                    return
                }
                
                do {
                    let drug: Drug = try JSONDecoder().decode(Drug.self, from: data!)
                    completion(.success(drug))
                } catch {
                    print("Error while decoding json")
                }
            }.resume()
        }
    }
    
    func getItemsOn(query: String = "",
                    startingFrom offset: Int = 0,
                    amount limit: Int = 10,
                    completion: @escaping (Result<[Drug], Error>) -> ()) {
        
        networkQueue.async {

            var components = URLComponents(string: Constants.baseURL + Constants.APIMethods.index.rawValue)!
            components.queryItems = [URLQueryItem(name: "offset", value: "\(offset)"),
                                     URLQueryItem(name: "limit", value: "\(limit)"),
                                     URLQueryItem(name: "search", value: "\(query)")]
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = HttpMethod.get.rawValue
            
            self.urlSession.dataTask(with: request) { [unowned self] data, response, error in
                guard validateResponse(data, response, error) else {
                    completion(.failure(error!))
                    return
                }
                
                do {
                    let index: [Drug] = try JSONDecoder().decode([Drug].self, from: data!)
                    completion(.success(index))
                } catch {
                    print("Error while decoding json")
                }
            }.resume()
        }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (Result<URL,Error>) -> ()) {
        self.urlSession.downloadTask(with: url) { tempURL, response, error in
            guard error == nil, let tempURL = tempURL else {
                completion(.failure(error!))
                print(error!.localizedDescription)
                return
            }
            
            guard let newImageURL = URLComponents(string: FileManager.default.imagesDir.absoluteString + url.lastPathComponent)?.url else { return }
            if FileManager.default.fileExists(atPath: newImageURL.path) {
                completion(.success(newImageURL))
            } else {
                do {
                    try FileManager.default.moveItem(at: tempURL, to: newImageURL)
                    completion(.success(newImageURL))
                } catch {
                    print("Can not move image at \(tempURL) to \(newImageURL)")
                }
            }
        }.resume()
    }
    
    func downloadImageFor(drug: Drug, completion: @escaping (Result<URL,Error>) -> ()) {
        networkQueue.async {
            guard let imagePath = drug.imageURL,
                  let imageURL = URLComponents(string: Constants.baseURL + imagePath)?.url else {
                print("Item does not contain image")
                return
            }
            self.downloadImage(at: imageURL) { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(_):
                    return
                }
            }
        }
    }
    
    func downloadCategoryIconFor(drug: Drug, completion: @escaping (Result<URL,Error>) -> ()) {
        networkQueue.async {
            guard let imagePath = drug.categories?.icon,
                  let imageURL = URLComponents(string: Constants.baseURL + imagePath)?.url else {
                print("Item does not contain image")
                return
            }
            self.downloadImage(at: imageURL) { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(_):
                    return
                }
            }
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
}


extension NetworkService: ServiceProtocol {
    var description: String {
        return "NetworkService"
    }
}
