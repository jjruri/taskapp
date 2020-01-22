//
//  ViewController.swift
//  taskapp
//
//  Created by 佐藤淳哉 on 2020/01/13.
//  Copyright © 2020 Junya.Satou. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var task:  Task!
    // Realmインスタンスを取得する
    let realm = try! Realm()

    // DB内のタスクが格納されるリストをつくる
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    
    //画面描画い時にテーブルビューを使えるようにする
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    //タスクの数はDBからの返答を保持すインスタンス（変数）であるtaskArrayの数を入れる
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //セルを生成して、中身を決める処理
    //なので利用できるセルを持ってきて
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]//セル番号と同じtaskArrayの中身をとってきてtaskにいれる（インスタンス化）
        cell.textLabel?.text = task.title//cellのテキストラベルにtaskのタイトルを入れる
        
        let formatter = DateFormatter()//データフォーマットのメソッドをインスタンス化
        //formatter.timeZone = TimeZone.current
        //formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"//型式をyyyymmddと時分にする
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString //参考（https://weblabo.oscasierra.net/swift-uitableview-2/）
        //print(dateString)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
            self.realm.delete(self.taskArray[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue" /*編集のためにタスクが押下された場合の処理*/{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task /*遷移後の画面で使うtaskという変数に対して*/ = taskArray[indexPath!.row]/*taskArrayの内容を渡す*/
        }
        else/*新規タスク追加のために+ボタンが押下された場合の処理*/{
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 /* タスクが何かしら登録済みの場合*/{
                task.id = taskArray.max(ofProperty: "id")! + 1
                inputViewController.task = task
        }
            else/*初めてのタスク追加で空っぽの場合*/{
                inputViewController.task = task
            }
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print(taskArray)
    }

}
