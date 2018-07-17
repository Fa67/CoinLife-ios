//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_upbit {
    static var is_doing = false
    
    init() {
        if (!ticker_upbit.is_doing){

            if coin_kind.count != 0{
                var whole_str = "CRIX.UPBIT.KRW-BTC"
                
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "Upbit") || !(whole_str.contains("CRIX.UPBIT.KRW-" + coin_kind[i][0].uppercased() + "")  ){
                        //print(coin_kind[i][0])
                        if (coin_kind[i][0] == "BCH"){
                            whole_str = whole_str + ",CRIX.UPBIT.KRW-" + "BCC"
                        }else{
                            whole_str = whole_str + ",CRIX.UPBIT.KRW-" + coin_kind[i][0]
                        }
                    }
                }
                
                let url = URL(string: "https://crix-api.upbit.com/v1/crix/recent?codes=" + whole_str)
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    
                    
                    
                    for i in 0...coin_kind.count - 1 {
                        var coin_tmp = coin_kind[i][0]
                        if (coin_kind[i][0] == "BCH"){
                            coin_tmp = "BCC"
                        }
                        if ( coin_kind[i][1] == "Upbit"){
                            if (text.contains("CRIX.UPBIT.KRW-" + coin_tmp)){
                                let lets_text = text.components(separatedBy: "CRIX.UPBIT.KRW-" + coin_tmp)[1]
                                coin_kind[i][2] = self.split(str: lets_text,w1: "\"tradePrice\":",w2: ".")
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
