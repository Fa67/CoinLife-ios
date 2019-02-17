//
//  poloniex_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func poloniex() {
    if coin_kind.count != 0{
        let url = URL(string: "https://poloniex.com/public?command=returnTicker")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.ascci.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            if !(text.contains("\"USDT_BTC\"")){return}
            
            let usbtc = Float(split(str: text.components(separatedBy: "\"USDT_BTC\"")[1],w1: "\"last\":\"",w2: "\","))
            
            for i in 0...coin_kind.count - 1 {
                if (coin_kind[i][1] == "Poloniex"){
                    if text.contains("\"USDT_" + coin_kind[i][0] + "\""){
                        let whole_str = text.components(separatedBy: "\"USDT_" + coin_kind[i][0] + "\"")[1]
                        coin_kind[i][2] = split(str: whole_str,w1: "\"last\":\"",w2: "\"")
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)!))//현재가 달러 환율 적용
                        let open = split(str: whole_str,w1: "\"percentChange\":\"",w2: "\"")
                        let tmp = round(Float(open)! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제외
                        if(tmp > 0) {//전일대비
                            coin_kind[i][3] = ( "+" + String(tmp))
                        }else{
                            coin_kind[i][3] = ( String(tmp))
                        }
                        coin_kind[i][5] = ("USDT")
                        coin_kind[i][6] = split(str: whole_str,w1: "\"quoteVolume\":\"",w2: "\"")
                    }
                    else if text.contains("\"BTC_" + coin_kind[i][0] + "\""){
                        let main_coin_str = text.components(separatedBy: "\"BTC_" + coin_kind[i][0] + "\"")[1]
                        coin_kind[i][2] = split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")
                        let open = split(str: main_coin_str,w1: "\"percentChange\":\"",w2: "\"")//전일대비
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)! * usbtc!))//현재가 달러 환율 적용
                        let tmp = round(Float(open)! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                        if(tmp > 0) {
                            coin_kind[i][3] = ( "+" + String(tmp))
                        }else{
                            coin_kind[i][3] = ( String(tmp))
                        }
                        coin_kind[i][5] = ("BTC")
                        coin_kind[i][6] = split(str: main_coin_str,w1: "\"quoteVolume\":\"",w2: "\"")
                    }else{
                        coin_kind[i][2] = "미지원"
                        coin_kind[i][3] = "미지원"
                    }
                }
                
            }
            
            if primium_change == "Poloniex"{
                
                primium = []
                primium.append(["BTC",String(Int(usbtc! * Float(table_controller.usd)!))])
                for i in 0...coin_kind.count - 1 {
                    if text.contains("\"USDT_" + coin_kind[i][0].uppercased() + "\""){
                        let tmp = text.components(separatedBy: "\"USDT_" + coin_kind[i][0].uppercased() + "\"")[1]
                        let value = Float(split(str: tmp,w1: "\"last\":\"",w2: "\""))
                        primium.append([coin_kind[i][0].uppercased(),String(Int(value! * Float(table_controller.usd)!))])
                    }else if text.contains("\"BTC_" + coin_kind[i][0].uppercased() + "\""){
                        let tmp = text.components(separatedBy: "\"BTC_" + coin_kind[i][0].uppercased() + "\"")[1]
                        let value = Float(split(str: tmp,w1: "\"last\":\"",w2: "\""))
                        primium.append([coin_kind[i][0].uppercased(),String(Int(value! * Float(table_controller.usd)! * usbtc!))])
                    }
                }
                
            }
        }
        task.resume()
    }
}
