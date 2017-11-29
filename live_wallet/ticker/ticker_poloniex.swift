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
                    
                    let usbtc = Float(text.components(separatedBy: "\"USDT_BTC\"")[1].components(separatedBy: "\"last\":\"")[1].components(separatedBy: "\",")[0])//btc usd 가격
                    
                    for i in 0...coin_kind.count - 1 {
                        if ( coin_kind[i][1] == "Poloniex" && coin_kind[i][0] == "BTC"){
                            coin_kind[i][2] = String(Int(Float(TodayViewController.usd)! * usbtc!))//가격 저장
                            let open = text.components(separatedBy: "\"USDT_BTC")[1].components(separatedBy: "\"percentChange\":\"")[1].components(separatedBy: "\"")[0]//24시간전 가격
                            let tmp = round(Float(open)! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제외
                            
                        }
                        else if coin_kind[i][1] == "Poloniex" && text.contains("\"BTC_" + coin_kind[i][0] + "\""){
                            let main_coin_str = text.components(separatedBy: "\"BTC_" + coin_kind[i][0] + "\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")//현재가격
                            let open = self.split(str: main_coin_str,w1: "\"percentChange\":\"",w2: "\"")//전일대비
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//현재가 달러 환율 적용
                            let tmp = round(Float(open)! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                           
                        }else if (coin_kind[i][1] == "Poloniex"){
                            coin_kind[i][2] = "미지원"
                           
                        }
                    }
  
                   
                    //ticker_poloniex.is_doing = false
                }
                task.resume()
            }
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}


