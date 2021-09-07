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
    
    // 이 메소드가 동작하는 스레드는 해당 노티피케이션이 발생한 스레드와 동일한 스레드이기 때문에 UI관련된 작업은 메인 스레드를 지정해줘야 함
    @objc func didReceiveFriendsNotification(_ noti: Notification) {
        guard let friends: [Friend] = noti.userInfo?["friends"] as? [Friend] else { return }
        
        self.friends = friends
        
        // 이 코드를 제외한 나머지 코드는 모두 백그라운드에서 실행되는 중
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveFriendsNotification(_:)), name: DidReceiveFriendsNofitication, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestFreinds()
    }
}

