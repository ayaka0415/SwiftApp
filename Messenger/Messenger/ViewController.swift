//
//  ViewController.swift
//  Messenger
//
//  Created by Owner on 2020/06/11.
//  Copyright © 2020 ALJ. All rights reserved.
//

import UIKit
import  NCMB

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var users = NSArray()//ユーザデータ
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loginCheck()
    }
    
    func loginCheck(){
        if(NCMBUser.current() != nil) {
            print("ログイン済み")
            fetchUserList()
        } else {
            print("未ログイン")
            //ログイン画面還移
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        NCMBUser.logOut()
        self.loginCheck()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        let user = users.object(at: indexPath.row) as! NCMBUser
        cell.textLabel!.text = user.userName
        return cell
    }
    
    // ユーザ取得
    func fetchUserList(){
        // 取得対象のテーブルを"user"に指定
        let query = NCMBQuery(className: "user")
        // 取得条件として自分以外の条件追加
        query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
        // データ取得
        query?.findObjectsInBackground({(objects, error)in
            if (error != nil){
                print("ユーザ取得失敗:\(error)")
            }else{
                print("ユーザ取得成功:\(objects)")
                self.users = objects as! NSArray
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users.object(at: indexPath.row) as! NCMBUser
        let myUser = NCMBUser.current()!
        self.createRoom(myUser: myUser, selectedUser: selectedUser)
    }
    
    func createRoom(myUser:NCMBUser, selectedUser:NCMBUser){
        let room = NCMBObject(className: "Room")
        room?.setObject("\(myUser.userName) <--> \(selectedUser.userName)",forKey: "roomName")
        room?.setObject([myUser,selectedUser], forKey: "users")
        room?.saveInBackground({(error) in
            if(error != nil) {
                print("Room保存失敗:\(error)")
            }else{
                print("Room保存成功:\(room)")
               
                self.performSegue(withIdentifier: "toMessage", sender: room)
            }
        })
        
    }
    
    func checkRoomExist(myUser:NCMBUser,selectedUser:NCMBObject){
        let query = NCMBQuery(className: "Room")
        
        query?.findObjectsInBackground({(objects, error) in
            if (error != nil) {
                print("RoomUser取得失敗:\(error)")
            } else {
                print("RoomUser取得成功:\(objects)")
                if (objects?.count)! > 0 {
                    print("Room作成済み")
                    
                    let room = objects![0] as! NCMBObject
                    self.performSegue(withIdentifier: "toMessage", sender: room)
                } else {
                    print("Room未作成")
                    self.createRoom(myUser: myUser, selectedUser: selectedUser as! NCMBUser)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessage"{
            let vc = segue.destination as! MessageViewController
            vc.room = sender as! NCMBObject
        }
    }
}
