//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_poloniex {
    static var is_doing = false
    
    init() {
        if (!ticker_poloniex.is_doing){
 
            //ticker_poloniex.is_doing = true
            if coin_kind.count != 0{
                let url = URL(string: "https://poloniex.com/public?command=returnTicker")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.ascci.rawValue))
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    if !(text.contains("\"USDT_BTC\"")){return}
                    
                    let usbtc = Float(self.split(str: text.components(separatedBy: "\"USDT_BTC\"")[1],w1: "\"last\":\"",w2: "\","))
                    
                    for i in 0...coin_kind.count - 1 {
                        if (coin_kind[i][1] == "Poloniex"){
                            if text.contains("\"USDT_" + coin_kind[i][0] + "\""){
                                let whole_str = text.components(separatedBy: "\"USDT_" + coin_kind[i][0] + "\"")[1]
                                coin_kind[i][2] = self.split(str: whole_str,w1: "\"last\":\"",w2: "\"")
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//현재가 달러 환율 적용

                            }
                            else if text.contains("\"BTC_" + coin_kind[i][0] + "\""){
                                let main_coin_str = text.components(separatedBy: "\"BTC_" + coin_kind[i][0] + "\"")[1]
                                coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")
                              
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//현재가 달러 환율 적용

                            }else{
                                coin_kind[i][2] = "미지원"

                            }
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


