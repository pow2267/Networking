//
//  ViewController.swift
//  Networking
//
//  Created by kwon on 2021/09/04.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier: String = "friendCell"
    var friends: [Friend] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        let friend: Friend = self.friends[indexPath.row]
        
        cell.textLabel?.text = friend.name.full
        cell.detailTextLabel?.text = friend.email
        
        guard let imageUrl: URL = URL(string: friend.picture.thumbnail) else {
            return cell
        }
        
        guard let imageData: Data = try? Data(contentsOf: imageUrl) else {
            return cell
        }
        
        cell.imageView?.image = UIImage(data: imageData)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url: URL = URL(string: "https://randomuser.me/api/?results=20&inc=name,email,picture") else {
            return
        }
        
        // 실질적으로 실행되는 것 1) 세선 만들기
        let session: URLSession = URLSession(configuration: .default)
        
        // 실질적으로 실행되는 것 2) 데이터 테스크 만들기                 // 클로저는 3) 뒤에 실행된 게 성공하면 실행됨
        let dataTask: URLSessionDataTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let data = data else {
                return
            }
            
            do {
                let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                self.friends = apiResponse.results
                self.tableView.reloadData()
            } catch (let err) {
                print(err.localizedDescription)
            }
        })
        
        // 실질적으로 실행되는 것 3) 데이터 테스크 실행하기
        dataTask.resume()
    }
}

