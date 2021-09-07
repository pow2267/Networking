//
//  Request.swift
//  Networking
//
//  Created by kwon on 2021/09/07.
//

import Foundation

let DidReceiveFriendsNofitication: Notification.Name = Notification.Name("DidReceiveFriends")

func requestFreinds() {
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
            
            NotificationCenter.default.post(name: DidReceiveFriendsNofitication, object: nil, userInfo: ["friends": apiResponse.results])
        } catch (let err) {
            print(err.localizedDescription)
        }
    })
    
    // 실질적으로 실행되는 것 3) 데이터 테스크 실행하기
    dataTask.resume()
}
