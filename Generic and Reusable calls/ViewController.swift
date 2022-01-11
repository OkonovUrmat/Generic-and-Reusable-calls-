//
//  ViewController.swift
//  Generic and Reusable calls
//
//  Created by Urmat on 11/1/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension URLSession {
    enum CustomError: Error {
        case invalidUrl
        case invalidData
    }
    
    func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completionHandler: @escaping(Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            completionHandler(.failure(CustomError.invalidUrl))
            return
        }
        
        let task = self.dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.failure(CustomError.invalidData))
                }
                return
            }
            
            
        }
        
    }
}
