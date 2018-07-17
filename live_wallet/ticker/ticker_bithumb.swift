//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bithumb {
    static var is_doing = false
    
    init() {
        if (!ticker_bithumb.is_doing){
            //ticker_bithumb.is_doing = true
            if coin_kind.count != 0{
                let url = URL(string: "https://api.bithumb.com/public/ticker/All")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    if !(text.contains("status\":\"0000\"")){return}
                    for i in 0...coin_kind.count - 1 {
                        if coin_kind[i][1] == "Bithumb" && text.contains(coin_kind[i][0]){
                            let main_coin_str = text.components(separatedBy: coin_kind[i][0])[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"closing_price\":\"",w2: "\"")//현재가

                        }else if (coin_kind[i][1] == "Bithumb"){
                            coin_kind[i][2] = "미지원"

                        }
                    }
                    
                }
                task.resume()
            }
        }
    }
    
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
}
