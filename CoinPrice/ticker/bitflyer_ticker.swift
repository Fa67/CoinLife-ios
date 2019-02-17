//
//  bitflyer_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func bitflyer() {
    if coin_kind.count != 0{
        for i in 0...coin_kind.count - 1 {
            if ( coin_kind[i][1] == "BitFlyer"){
                let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=btc_jpy")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    
                    if (text.contains("\"ltp\":") && coin_kind[i][0] == "BTC"){
                        coin_kind[i][2] = split(str: text,w1: "\"ltp\":",w2: ",")
                        coin_kind[i][3] = "미지원"
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.jpy)! * 0.01))
                        coin_kind[i][5] = ("JPY")
                        coin_kind[i][6] = split(str: text,w1: "\"volume\":",w2: ",")
                        //usbtc = Float(coin_kind[i][2])!
                    }else if(text.contains("\"ltp\":")){
                        let btc_tmp = Float(split(str: text,w1: "\"ltp\":",w2: ","))
                        let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=" + coin_kind[i][0].lowercased() + "_btc")
                        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                            guard let data = data, error == nil else { return }
                            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                            //print(text)
                            if (text.contains("\"ltp\":")){
                                coin_kind[i][2] = split(str: text,w1: "\"ltp\":",w2: ",")
                                coin_kind[i][3] = "미지원"
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.jpy)! * 0.01 * Float(btc_tmp!)))
                                if primium_change == "BitFlyer"{
                                    
                                }
                                coin_kind[i][5] = ("BTC")
                                coin_kind[i][6] = split(str: text,w1: "\"volume\":",w2: ",")
                            }else {
                                coin_kind[i][2] = "미지원"
                                coin_kind[i][3] = "미지원"
                            }
                        }
                        task.resume()
                    }
                    else {
                        coin_kind[i][2] = "미지원"
                        coin_kind[i][3] = "미지원"
                    }
                }
                task.resume()
            }
        }
    }
}
