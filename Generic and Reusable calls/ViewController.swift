//
//  ViewController.swift
//  Generic and Reusable calls
//
//  Created by Urmat on 11/1/22.
//

import UIKit

struct User: Codable {
    let name: String
    let email: String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    struct Constants {
        static let usersURL = URL(string: "https://jsonplaceholder.typicode.com/users")
    }
    
    var models = [Codable]()
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        fetch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        table.frame = view.bounds
    }
    
    func fetch() {
        URLSession.shared.request(url: Constants.usersURL, expecting: [User].self) { [weak self] result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self?.models = users
                    self?.table.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = (models[indexPath.row] as? User)?.name
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
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
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
    }
}
