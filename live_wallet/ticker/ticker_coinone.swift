//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_coinone {
    static var is_doing = false
    
    init() {
        if (!ticker_coinone.is_doing){
            //ticker_coinone.is_doing = true
            if coin_kind.count != 0{
                let url = URL(string: "https://api.coinone.co.kr/ticker?currency=all")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.ascii.rawValue))
                    let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                    if !(text.contains("btc")){return}
                    for i in 0...coin_kind.count - 1 {
                        if coin_kind[i][1] == "Coinone" && text.contains("\"" + coin_kind[i][0].lowercased() + "\""){
                            let main_coin_str = text.components(separatedBy: coin_kind[i][0].lowercased())[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")

                        }else if (coin_kind[i][1] == "Coinone"){
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

