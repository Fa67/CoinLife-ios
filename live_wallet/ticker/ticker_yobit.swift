//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_yobit {
    static var is_doing = false
    
    init() {
        if (!ticker_yobit.is_doing){
            //ticker_bitfinex.is_doing = true
            if coin_kind.count != 0{
                let url = URL(string: "https://yobit.net/api/3/info")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let textt = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    
                    var whole_str = "btc_usd"
                    
                    for i in 0...coin_kind.count - 1 {
                        if ( coin_kind[i][1] == "Yobit") || !(whole_str.contains(coin_kind[i][0].lowercased() + "_btc") ){
                            if (coin_kind[i][0].lowercased() == "bch"){
                                if textt.contains("\"bcc_btc\""){
                                   whole_str = whole_str + "-bcc_btc"
                                }
                                whole_str = whole_str + "-bcc_" + "btc"
                            }else{
                                if textt.contains("\"" + coin_kind[i][0].lowercased() + "_btc\""){
                                    whole_str = whole_str + "-" + coin_kind[i][0].lowercased() + "_btc"
                                }
                            }
                        }
                    }
                    
                    let url = URL(string: "https://yobit.net/api/3/ticker/" + whole_str)
                    let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                        guard let data = data, error == nil else { return }
                        let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                       
                        
                        var btc_usd = Float(0)
                        if (text.contains("\"btc_usd\"")){
                            let lets_text = text.components(separatedBy: "\"btc_usd\"")[1]
                            btc_usd = Float(self.split(str: lets_text,w1: "\"last\":",w2: ","))!

                            for i in 0...coin_kind.count - 1 {
                                var coin_tmp = coin_kind[i][0].lowercased()
                                if (coin_tmp == "bch"){
                                    coin_tmp = "bcc"
                                }
                                if ( coin_kind[i][1] == "Yobit"){
                                    if (text.contains("\"" + coin_tmp + "_usd\"")){
                                        let lets_text = text.components(separatedBy: "\"btc_usd\"")[1]
                                        coin_kind[i][2] = self.split(str: lets_text,w1: "\"last\":",w2: ",")
                                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
 
                                    }else if (text.contains("\"" + coin_tmp + "_btc\"")){
                                        let lets_text = text.components(separatedBy: "\"" + coin_tmp + "_btc\"")[1]
                                        coin_kind[i][2] = self.split(str: lets_text,w1: "\"last\":",w2: ",")
                                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * btc_usd))//달러 적용 현재가

                                    }else if (text.contains("\"error\", 11010")) {
                                        coin_kind[i][2] = "ip"
                                    }else {
                                        coin_kind[i][2] = "미지원"
                                    }
                                }
                               
                            }
                        }
                    }
                    task.resume()
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
