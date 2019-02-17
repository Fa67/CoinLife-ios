//
//  bittrex_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func bittrex() {
    if coin_kind.count != 0{
        let url = URL(string: "https://www.bittrex.com/api/v1.1/public/getmarketsummaries")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            if !(text.contains("\"USDT-BTC")){return}
            
            let usbtc  = Float(split(str: text.components(separatedBy: "\"USDT-BTC")[1],w1: "\"Last\":",w2: ","))
            
            for i in 0...coin_kind.count - 1 {
                let coin_n_tmp = coin_kind[i][0].uppercased()
                if coin_n_tmp == "BAB"{
                    //coin_n_tmp = "BCH"
                }
                
                if coin_kind[i][1] == "BitTrex"{
                    if text.contains("\"USDT-" + coin_n_tmp + "\""){
                        let main_coin_str = text.components(separatedBy: "\"USDT-" + coin_n_tmp + "\"")[1]
                        coin_kind[i][2] = split(str: main_coin_str,w1: "\"Last\":",w2: ",")
                        let open  = split(str: main_coin_str,w1: "\"PrevDay\":",w2: ",")//24시간전
                        let rslt  = ((Float(coin_kind[i][2])! - Float(open)!) / Float(open)! * 100)//전일대비
                        let tmp = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                        if(tmp > 0) {
                            coin_kind[i][3] = ( "+" + String(tmp))
                        }else{
                            coin_kind[i][3] = ( String(tmp))
                        }
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)!))//달러 적용 현재가
                        coin_kind[i][5] = ("USDT")
                        coin_kind[i][6] = split(str: main_coin_str,w1: "\"Volume\":",w2: ",")
                    }
                    else if text.contains("\"BTC-" + coin_n_tmp + "\""){
                        let main_coin_str = text.components(separatedBy: "\"BTC-" + coin_n_tmp + "\"")[1]
                        coin_kind[i][2] = split(str: main_coin_str,w1: "\"Last\":",w2: ",")//현재가격
                        let open  = split(str: main_coin_str,w1: "\"PrevDay\":",w2: ",")//24시간전
                        let rslt  = ((Float(coin_kind[i][2])! - Float(open)!) / Float(open)! * 100)//전일대비
                        let tmp = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                        if(tmp > 0) {
                            coin_kind[i][3] = ( "+" + String(tmp))
                        }else{
                            coin_kind[i][3] = ( String(tmp))
                        }
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)! * usbtc!))//달러 적용 현재가
                        coin_kind[i][5] = ("BTC")
                        coin_kind[i][6] = split(str: main_coin_str,w1: "\"Volume\":",w2: ",")
                    }
                    else{
                        coin_kind[i][2] = "미지원"
                        coin_kind[i][3] = "미지원"
                    }
                }
                
                
            }
            if primium_change == "BitTrex"{
                primium = []
                primium.append(["BTC",String(Int(usbtc! * Float(table_controller.usd)!))])
                for i in 0...coin_kind.count - 1 {
                    let coin_n_tmp = coin_kind[i][0].uppercased()
                    if coin_n_tmp == "BAB"{
                        //coin_n_tmp = "BCH"
                    }
                    if text.contains("\"USDT-" + coin_n_tmp + "\""){
                        let tmp = text.components(separatedBy: "\"USDT-" + coin_n_tmp + "\"")[1]
                        let value = Float(split(str: tmp,w1: "\"Last\":",w2: ","))
                        primium.append([coin_kind[i][0].uppercased(),String(Int(value! * Float(table_controller.usd)!))])
                    }
                    else if text.contains("\"BTC-" + coin_n_tmp + "\""){
                        let tmp = text.components(separatedBy: "\"BTC-" + coin_n_tmp + "\"")[1]
                        let value = Float(split(str: tmp,w1: "\"Last\":",w2: ","))
                        primium.append([coin_kind[i][0].uppercased(),String(Int(value! * Float(table_controller.usd)! * usbtc!))])
                    }
                }
            }
        }
        task.resume()
    }
}
