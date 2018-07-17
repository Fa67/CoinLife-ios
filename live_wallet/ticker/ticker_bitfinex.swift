//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bitfinex {
    static var is_doing = false
    
    init() {
        if (!ticker_bitfinex.is_doing){
            //ticker_bitfinex.is_doing = true
            if coin_kind.count != 0{
                var whole_str = "fUSD"

                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "BitFinex") || !(whole_str.contains("t" + coin_kind[i][0] + "USD")){
                        //print(coin_kind[i][0])
                        if (coin_kind[i][0] == "QTUM"){
                            whole_str = whole_str + ",t" + "QTM" + "USD"
                        }else if(coin_kind[i][0] == "DASH"){
                            whole_str = whole_str + ",t" + "DSH" + "USD"
                        }else{
                           whole_str = whole_str + ",t" + coin_kind[i][0] + "USD"
                        }
                        
                    }
                }
                
                let url = URL(string: "https://api.bitfinex.com/v2/tickers?symbols=" + whole_str)
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
 
                    
                    //var coin_cnt = whole_str.components(separatedBy: ",")
                    for i in 0...coin_kind.count - 1 {
                        
                        var coin_tmp = coin_kind[i][0]
                        if (coin_kind[i][0] == "QTUM"){
                            coin_tmp = "QTM"
                        }else if(coin_kind[i][0] == "DASH"){
                            coin_tmp = "DSH"
                        }else if(coin_kind[i][0] == "BCC"){
                            coin_tmp = "BCH"
                        }
                        
                        if ( coin_kind[i][1] == "BitFinex"){
                            if (text.contains("\"t" + coin_tmp + "USD\"")){
                                let lets_text = text.components(separatedBy: "\"t" + coin_tmp + "USD\"")[1]
                                coin_kind[i][2] = lets_text.components(separatedBy: ",")[7]
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
 
                                
                            }else if (text.contains("\"error\", 11010")) {
                                coin_kind[i][2] = "ip"
                            }else {
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

