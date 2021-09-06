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
        cell.imageView?.image = nil // nil처리를 해줘야 cell 재활용 할 때 다른 사람의 이미지가 잘못들어가지 않음
        
        DispatchQueue.global().async {
            guard let imageUrl: URL = URL(string: friend.picture.thumbnail) else {
                return
            }
            
            // Data는 동기 메소드라서 이미지를 불러올 때까지 동작이 멈추게 됨. 그럼 불편하니까 백그라운드 큐에 넣어줌
            guard let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
            
            DispatchQueue.main.async {
                // image를 셋팅하기 전에 사용자가 스크롤을 하면 화면에 보여지는 cell의 index가 달라질 수 있으므로 index를 비교해주는 코드가 필요
                if let index: IndexPath = tableView.indexPath(for: cell) {
                    if index.row == indexPath.row {
                        cell.imageView?.image = UIImage(data: imageData)
                        // 댓글에서 알려준 방법 (이 메소드가 없으면 실행했을 때 셀을 눌러야만 사진이 보임)
                        cell.setNeedsLayout()
                        // cell.layoutIfNeeded() 이건 없어도 동작 함. 왜지?
                    }
                }
            }
        }
        
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
                
                // 이 코드를 제외한 나머지 코드는 모두 백그라운드에서 실행되는 중
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch (let err) {
                print(err.localizedDescription)
            }
        })
        
        // 실질적으로 실행되는 것 3) 데이터 테스크 실행하기
        dataTask.resume()
    }
}

