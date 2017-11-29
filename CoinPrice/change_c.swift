//
//  chart.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 16..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation
import UIKit
import SwiftChart
import NVActivityIndicatorView


class change_c_cell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
}

class change_c: UITableViewController  {
    
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        tableview.dataSource = self
        tableview.delegate = self
        
        self.tableView.isEditing = true
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool){
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tmp1 = sourceIndexPath.row
        let tmp2 = destinationIndexPath.row
        
        if tmp1 < tmp2{
            let f_change = section_change[tmp1]
            let s_change = section_change[tmp2]
            var end = 0
            for i in 0...coin_kind.count - 1 {
                if(coin_kind[i][1] == s_change){
                    end = i
                }
            }
            
            var tmp = end
            var i = 0
            for _ in 0...coin_kind.count - 1  {
                if i == tmp{
                    break
                }
                if(coin_kind[i][1] == f_change){
                    let movedObject = coin_kind[i]
                    //print(movedObject)
                    coin_kind.remove(at: i)
                    coin_kind.insert(movedObject, at: end)
                    tmp = tmp - 1
                }else{
                    i = i + 1
                }
            }

           
            
        }else{
            let f_change = section_change[tmp1]
            let s_change = section_change[tmp2]
            var end = 0
            for i in 0...coin_kind.count - 1 {
                if(coin_kind[i][1] == s_change){
                    end = i
                    break
                }
            }
            
            var tmp = end
            var i = coin_kind.count - 1
            for _ in 0...coin_kind.count - 1  {
                if i == tmp{
                    break
                }
                if(coin_kind[i][1] == f_change){
                    let movedObject = coin_kind[i]
                    print(movedObject)
                    coin_kind.remove(at: i)
                    coin_kind.insert(movedObject, at: end)
                    tmp = tmp + 1
                }else{
                    i = i  - 1
                }
            }
            
           
        }
        
        
  
        add_check_change()
        save_arr()
        table_controller.right_now_refresh = 1
    }
    //섹션 별 개수 가져오기
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section_change.count
    }
    
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "change_c_cell", for: indexPath) as! change_c_cell
        cell.name.text = section_change[indexPath.row]
        
        return cell
        
    }
    func add_check_change(){
        if(!(coin_kind.count == 0)){
            section_change = []
            for i in 0...coin_kind.count - 1 {
                if(!section_change.contains(coin_kind[i][1])){
                    if !(coin_kind[i][4] == "wallet"){
                        
                    }
                    section_change.append(coin_kind[i][1]);
                }
            }
            section_change2 =  [[[String]]](repeating:
                [[String]](repeating: [], count: 0), count: section_change.count)
            for ii in 0...section_change.count - 1 {
                for i in 0...coin_kind.count - 1 {
                    if(coin_kind[i][1].contains(section_change[ii])){
                        //print(coin_kind[i][4])
                        if !(coin_kind[i][4] == "wallet"){
                            section_change2[ii].append(coin_kind[i])
                        }
                    }
                }
            }
        }
    }
    
    func save_arr() {
        var text = ""
        if !(coin_kind.count == 0){
            for i in 0...coin_kind.count - 1 {
                if coin_kind[i].count == 5{
                    if (coin_kind[i][4] == "wallet"){
                        text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + coin_kind[i][4] + "#")
                    }else{
                        text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                    }
                }else{
                    text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                }
                
            }
        }
        
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(text), forKey: "arr")
        defaults?.synchronize()
    }
    
}



