//
//  ViewController.swift
//  taskapp
//
//  Created by 佐藤淳哉 on 2020/01/13.
//  Copyright © 2020 Junya.Satou. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    //パーツのアウトレット接続
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryFilter: UISearchBar!
    
    // Realmインスタンス
    let realm = try! Realm()
    
    //サーチバーインスタンス化
    var category:UISearchBar = UISearchBar()
    
    //var searchText:String = UISearchBar().text!
    
    // DB内のタスク配列
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //宣言しろっていうから、一回varにして上書きしようとしてみる
    //var searchResult = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    /*宣言しようとしてみる
     var searchResult:Results<Task>!//同じ型にして初期化は!で空を許してあげればこれでもいける
    */
 
    //画面描画時にテーブルビューを使えるようにする
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        */
        tableView.delegate = self
        tableView.dataSource = self
        categoryFilter.delegate = self
        category = UISearchBar()
        category.showsCancelButton = true
    }
    
    @objc func dismissKeyboard(){
        // タップした時にキーボードを閉じる用
        view.endEditing(true)
    }
 

    //ここから先、何か行われた時の処理をまとめて記載する
    
    /*サーチバーに何も入らなかった時と使われた時の挙動を記載する
    func serchItems(serchText:String){
        serchText = taskArray.filter(taskArray, in return taskArray.contains(serchText)) as Array
    }
 */

    //タスクの数はDBからの返答を保持すインスタンス（変数）であるtaskArrayの数を入れる
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("タスクアレイは\(taskArray.count)件入ってる")
        return taskArray.count
    }
    
    func searchItems(searchText: String) {
        //入力されたワードと一致したレコードを返す
        if searchText != "" {
            //let searchResult = try! Realm().objects(Task.self).filter( "category = '"+searchText+"'" )
            taskArray = try! Realm().objects(Task.self).filter( "category contains[c] %@" , searchText )
            //print("filter後のtaskArrayの中身：\(taskArray)")
            /*if taskArray.count == 0 {
                print("検索結果がゼロだよ")
                alert(title: "みつかりませんでした", message: "検索ワードを変更してください", btnText: "OK")
            }*/
        }
        else{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            //print("filterされてない時のraskArrayの中身\(taskArray)")
        }
        tableView.reloadData()
    }
    
    //セルを生成して、中身を決める処理
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()//データフォーマットのメソッドをインスタンス化
        //formatter.timeZone = TimeZone.current
        //formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"//型式をyyyymmddと時分にする
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString //参考（https://weblabo.oscasierra.net/swift-uitableview-2/）
        //print(dateString)
        //print("セル生成時のアレイ\(taskArray)")
        return cell
        
    }
    
    //選択したセル番号を引き渡すためのメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //スワイプした時に何を出すか（削除）
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
            inputViewController.task /*遷移後の画面で使うtaskという変数に対して*/ = taskArray[indexPath!.row]/*該当する行番号のtaskArray内容を渡す*/
            //print("セルタップ時のtaskArrayの中身は\(taskArray)")
        }
        else/*新規タスク追加のために+ボタンが押下された場合の処理*/{
            let task = Task()
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0 /* タスクが何かしら登録済みの場合*/{
                task.id = taskArray.max(ofProperty: "id")! + 1
                inputViewController.task = task
        }
            else/*初めてのタスク追加で空っぽの場合*/{
                inputViewController.task = task
            }
            
        }
    }
        
    
    
    

    
    
    
   /*
    func alert( title: String, message: String, btnText: String ){
       let alert = UIAlertController(
            title: "該当なし",
            message: "該当するタスクがありません。検索ワードを変更してください",
            preferredStyle: .alert
       )
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
       alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
 */
    
    //サーチバーに文字が入った時に呼ばれる（他のメソッドも起動させる役割を持たせる）
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //サーチアイテムメソッドを起動させる
        searchItems(searchText: searchText)
        //テーブルを更新する
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        //print(taskArray)
    }
        
        
}
