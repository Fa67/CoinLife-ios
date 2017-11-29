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
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")//현재가격
                            let open = self.split(str: main_coin_str,w1: "\"yesterday_last\":\"",w2: "\"")//24시간전
                            let rslt  = ((Float(coin_kind[i][2])! - Float(open)!) / Float(open)! * 100)//전일대비
                            let tmp = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))
                            if(tmp > 0) {
                                coin_kind[i][3] = ( "+" + String(tmp))
                            }else{
                                coin_kind[i][3] = ( String(tmp))
                            }
                        }else if (coin_kind[i][1] == "Coinone"){
                            coin_kind[i][2] = "미지원"
                            coin_kind[i][3] = "미지원"
                        }
                    }
                    if primium_change == "Coinone" {
                        primium = []
                        for i in 0...coin_kind.count - 1 {
                            if text.contains("\"" + coin_kind[i][0].lowercased() + "\""){
                                let tmp = text.components(separatedBy: "\"" + coin_kind[i][0].lowercased() + "\"")[1]
                                //let name = tmp.components(separatedBy: "\":")[0].uppercased()
                                let value = Float(tmp.components(separatedBy: "\"last\":\"")[1].components(separatedBy: "\"")[0])
                                primium.append([coin_kind[i][0].uppercased(),String(Int(value!))])
                            }
                        }
                    }
                    //ticker_coinone.is_doing = false
                }
                task.resume()
            }
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}

