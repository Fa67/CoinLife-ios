//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bitflyer {
    static var is_doing = false
    
    init() {
        if (!ticker_bitflyer.is_doing){
            //ticker_bitflyer.is_doing = true
            if coin_kind.count != 0{
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "BitFlyer"){
                        let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=btc_jpy")
                        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                            guard let data = data, error == nil else { return }
                            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                            
                            if (text.contains("\"ltp\":") && coin_kind[i][0] == "BTC"){
                                coin_kind[i][2] = self.split(str: text,w1: "\"ltp\":",w2: ",")
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.jpy)! * 0.01))
                                //usbtc = Float(coin_kind[i][2])!
                            }else if(text.contains("\"ltp\":")){
                                let btc_tmp = Float(self.split(str: text,w1: "\"ltp\":",w2: ","))
                                let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=" + coin_kind[i][0].lowercased() + "_btc")
                                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                                    guard let data = data, error == nil else { return }
                                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                                    //print(text)
                                    if (text.contains("\"ltp\":")){
                                        coin_kind[i][2] = self.split(str: text,w1: "\"ltp\":",w2: ",")
                                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.jpy)! * 0.01 * Float(btc_tmp!)))
                                    }else {
                                        coin_kind[i][2] = "미지원"
                                    }
                                }
                                task.resume()
                            }
                            else {
                                coin_kind[i][2] = "미지원"
                            }
                        }
                        task.resume()
                    }
                }
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



