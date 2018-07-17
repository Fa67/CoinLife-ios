//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bittrex {
    static var is_doing = false
    
    init() {
        if (!ticker_bittrex.is_doing){

            if coin_kind.count != 0{
                let url = URL(string: "https://www.bittrex.com/api/v1.1/public/getmarketsummaries")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    if !(text.contains("\"USDT-BTC")){return}
                    
                    let usbtc  = Float(self.split(str: text.components(separatedBy: "\"USDT-BTC")[1],w1: "\"Last\":",w2: ","))

                    for i in 0...coin_kind.count - 1 {
                        var coin_n_tmp = coin_kind[i][0].uppercased()
                        if coin_n_tmp == "BCH"{
                            coin_n_tmp = "BCC"
                        }
                        if coin_kind[i][1] == "BitTrex"{
                            if text.contains("\"USDT-" + coin_n_tmp + "\""){
                                let main_coin_str = text.components(separatedBy: "\"USDT-" + coin_n_tmp + "\"")[1]
                                coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"Last\":",w2: ",")
    
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                            }
                            else if text.contains("\"BTC-" + coin_n_tmp + "\""){
                                let main_coin_str = text.components(separatedBy: "\"BTC-" + coin_n_tmp + "\"")[1]
                                coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"Last\":",w2: ",")//현재가격

                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//달러 적용 현재가
                            }
                            else{

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




