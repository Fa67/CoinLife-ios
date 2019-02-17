//
//  binance_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func binance() {
    if coin_kind.count != 0{
        let url = URL(string: "https://api.binance.com/api/v1/ticker/allPrices")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            if !(text.contains("symbol\":\"BTCUSDT\"")){return}
            
            let usbtc  = Float(split(str: text.components(separatedBy: "symbol\":\"BTCUSDT\"")[1],w1: "\"price\":\"",w2: "\""))
            
            for i in 0...coin_kind.count - 1 {
                let coin_n_tmp = coin_kind[i][0].uppercased()
                if coin_n_tmp == "BCH"{
                    //coin_n_tmp = "BCHABC"
                }
                if coin_n_tmp == "BSV"{
                    //coin_n_tmp = "BCHSV"
                }
                if coin_n_tmp == "BAB"{
                    //coin_n_tmp = "BCHABC"
                }
                if coin_kind[i][1] == "Binance"{
                    if text.contains("symbol\":\"" + coin_n_tmp + "USDT\""){
                        let main_coin_str = text.components(separatedBy: "symbol\":\"" + coin_n_tmp + "USDT\"")[1]
                        coin_kind[i][2] = split(str: main_coin_str,w1: "\"price\":\"",w2: "\"")
                        coin_kind[i][3] = "미지원"
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)!))//달러 적용 현재가
                        coin_kind[i][5] = ("USDT")
                        coin_kind[i][6] = "미지원"
                    }
                    else if text.contains("symbol\":\"" + coin_n_tmp + "BTC\""){
                        let main_coin_str = text.components(separatedBy: "symbol\":\"" + coin_n_tmp + "BTC\"")[1]
                        coin_kind[i][2] = split(str: main_coin_str,w1: "\"price\":\"",w2: "\"")
                        coin_kind[i][3] = "미지원"
                        coin_kind[i][2] = String((Float(coin_kind[i][2])! * Float(table_controller.usd)! * usbtc!))//달러 적용 현재가
                        coin_kind[i][5] = ("BTC")
                        coin_kind[i][6] = "미지원"
                    }
                    else{
                        coin_kind[i][2] = "미지원"
                        coin_kind[i][3] = "미지원"
                    }
                }
                
                
            }
            if primium_change == "Binance"{
                primium = []
                primium.append(["BTC",String(Int(usbtc! * Float(table_controller.usd)!))])
                for i in 0...coin_kind.count - 1 {
                    let coin_n_tmp = coin_kind[i][0].uppercased()
                    if coin_n_tmp == "BCH"{
                        //coin_n_tmp = "BCHABC"
                    }
                    if coin_n_tmp == "BSV"{
                        //coin_n_tmp = "BCHSV"
                    }
                    if coin_n_tmp == "BAB"{
                        //coin_n_tmp = "BCHABC"
                    }
                    if text.contains("symbol\":\"" + coin_n_tmp + "USDT\""){
                        let tmp = text.components(separatedBy: "symbol\":\"" + coin_n_tmp + "USDT\"")[1]
                        let value = Float(split(str: tmp,w1: "\"price\":\"",w2: "\""))
                        primium.append([coin_kind[i][0].uppercased(),String(Int(value! * Float(table_controller.usd)!))])
                    }
                    else if text.contains("symbol\":\"" + coin_n_tmp + "BTC\""){
                        let tmp = text.components(separatedBy: "symbol\":\"" + coin_n_tmp + "BTC\"")[1]
                        let value = Float(split(str: tmp,w1: "\"price\":\"",w2: "\""))
                        primium.append([coin_kind[i][0].uppercased(),String((value! * Float(table_controller.usd)! * usbtc!))])
                    }
                }
            }
        }
        task.resume()
    }
}
