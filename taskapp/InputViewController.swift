//
//  InputViewController.swift
//  taskapp
//
//  Created by 佐藤淳哉 on 2020/01/14.
//  Copyright © 2020 Junya.Satou. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task:  Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    func setNotification (task: Task){
        let content = UNMutableNotificationContent()
        
        //通知に表示する内容を指定する
        if task.title == "" {
            content.title = "無題"
        }
        else{
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "詳細なし"
        }
        else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
    
    //通知のトリガーを設定する
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([ .year, .month, .day, .hour, .minute], from: task.date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request){ (error) in print(error ?? "ローカル通知OK")}
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
