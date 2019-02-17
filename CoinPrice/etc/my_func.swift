//
//  my_func.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation
import ZAlertView

func split(str:String,w1:String,w2:String) -> String{
    var tmp = ""
    if (str.contains(w1)){
        tmp = str.components(separatedBy: w1)[1]
    }else{
        return "0"
    }
    if (tmp.contains(w2)){
        tmp = tmp.components(separatedBy: w2)[0]
    }else{
        return "0"
    }
    if (Float(tmp) == nil){
        return "0"
    }
    return tmp
}

func split_s(str:String,w1:String,w2:String) -> String{
    var tmp = ""
    if (str.contains(w1)){
        tmp = str.components(separatedBy: w1)[1]
    }else{
        return "0"
    }
    if (tmp.contains(w2)){
        tmp = tmp.components(separatedBy: w2)[0]
    }else{
        return "-0"
    }
    return tmp
}

//저장된 코인을 거래소별로 정리
func add_check_change(){
    if(!(coin_kind.count == 0)){
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
                        //print(coin_kind[i])
                        section_change2[ii].append(coin_kind[i])
                    }else{
                        //print("wallet")
                    }
                }
            }
        }
    }
}



//모든코인 정보 저장
func save_arr() {
    var text = ""
    if !(coin_kind.count == 0){
        for i in 0...coin_kind.count - 1 {
            if coin_kind[i].count == 7{
                if (coin_kind[i][4] == "wallet"){
                    //text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + coin_kind[i][4] + "#")
                }else{
                    text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                }
            }else{
                text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
            }
            
        }
    }
    //print(text)
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    defaults?.set(String(text), forKey: "arr")
    defaults?.synchronize()
}

//프리미엄 선택 팝업
func add_pri(){
    var dialog = SelectionDialog(title: "프리미엄 거래소 선택", closeButtonTitle: "닫기")
    func add_w_item(str:String){
        dialog.addItem(item: str, didTapHandler: { () in
            primium_change = str
            dialog.close()
        })
    }
    add_w_item(str: "Binance")
    add_w_item(str: "Bitfinex")
    add_w_item(str: "Bithumb")
    add_w_item(str: "BitTrex")
    add_w_item(str: "Coinone")
    add_w_item(str: "Poloniex")
    add_w_item(str: "Upbit")
    dialog.show()
}

//추가하려는 코인 배열에 입력
func choose_coin(kind: String){
    let dialog2 = ZAlertView(title: kind, message: "코인 종류를 입력해주세요.", isOkButtonLeft: false, okButtonText: "추가", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
        let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("coin_choose")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
        if !get_tmp.contains("@") && !get_tmp.contains("#") && !get_tmp.contains(" ") && !(get_tmp == "") && get_tmp.isAlphanumeric2{
            coin_kind.append([get_tmp.uppercased(), kind,"---","---","---","---","---"])
            save_arr()
            //list_refresh()
            scan_all_ticker()
        }else{
            let dialog = ZAlertView(title: "오류",message: "입력 값에 오류가 있습니다.",closeButtonText: "확인",closeButtonHandler: { alertView in alertView.dismissAlertView()})
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
    },cancelButtonHandler: { alertView in alertView.dismissAlertView()})
    dialog2.addTextField("coin_choose", placeHolder: "ex)BTC,BCH,ETH,ETC...")
    dialog2.show()
}

//콤마
func coma(str:String) ->String{
    var comback = ""
    var tmpp = str
    if tmpp.contains("."){
        comback = tmpp.components(separatedBy: ".")[1]
        tmpp = tmpp.components(separatedBy: ".")[0]
    }
    var price_tmp = tmpp
    var made_price = ""
    while price_tmp.count >= 3{
        let str_cnt = price_tmp.count
        let back = price_tmp.substring(from: price_tmp.index(price_tmp.endIndex, offsetBy: -3))
        price_tmp = price_tmp.substring(to: price_tmp.index(price_tmp.startIndex, offsetBy: str_cnt-3))
        if (made_price == ""){
            made_price = back
        }else{
            made_price = back + "," + made_price
        }
    }
    if !(price_tmp.count == 0){
        if (made_price == ""){
            made_price = price_tmp
        }else{
            made_price = price_tmp + "," + made_price
        }
    }
    if comback == ""{
        return made_price
    }else{
        return made_price + "." + comback
    }
}

func save_primium() {
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    defaults?.set(String(primium_change), forKey: "primium")
    defaults?.synchronize()
}

func save_kind() {
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    defaults?.set(String(kind_price), forKey: "kind")
    defaults?.synchronize()
}

/*
 //테이들 포스터치
 func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
 if tableView.isEditing == false {
 guard let indexPath = tableView.indexPathForRow(at: location) else {
 print("Nil Cell Found: \(location)")
 return nil
 }
 guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "candle") else { return nil }
 //print(indexPath)
 for i in 0...3{
 table_controller.send_data[i] = section_change2[indexPath[0]][indexPath[1]][i]
 }
 previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
 //print(location)
 /*
 guard let indexPath = tableView.indexPathForRow(at: location) else {
 print("Nil Cell Found: \(location)")
 return nil
 }
 guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "chart") else { return nil }
 //print(indexPath)
 for i in 0...3{
 table_controller.send_data[i] = section_change2[indexPath[0]][indexPath[1]][i]
 }
 previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
 */
 return detailVC
 }else {
 return nil
 }
 }
 //테이블 포스터치 클릭 시
 func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
 let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "candle") as! candle
 self.navigationController?.pushViewController(secondViewController, animated: true)
 }*/
