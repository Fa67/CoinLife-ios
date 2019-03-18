//
//  coinone.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func coinone() {
    if coin_kind.count != 0{
        let url = URL(string: "https://api.coinone.co.kr/ticker?currency=all")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.ascii.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            if !(text.contains("btc")){return}
            for i in 0...coin_kind.count - 1 {
                if coin_kind[i][1] == "Coinone" && text.contains("\"" + coin_kind[i][0].lowercased() + "\":"){
                    let main_coin_str = text.components(separatedBy: coin_kind[i][0].lowercased() + "\":")[1]
                    //print(main_coin_str)
                    coin_kind[i][2] = split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")
                    let open = split(str: main_coin_str,w1: "\"yesterday_last\":\"",w2: "\"")//24시간전
                    let rslt  = ((Float(coin_kind[i][2])! - Float(open)!) / Float(open)! * 100)//전일대비
                    let tmp = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))
                    if(tmp > 0) {
                        coin_kind[i][3] = ( "+" + String(tmp))
                    }else{
                        coin_kind[i][3] = ( String(tmp))
                    }
                    coin_kind[i][5] = ("KRW")
                    coin_kind[i][6] = split(str: main_coin_str,w1: "\"volume\":\"",w2: "\"")
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
                        let value = split(str: tmp,w1: "\"last\":\"",w2: "\"")
                        primium.append([coin_kind[i][0].uppercased(),(Int(value)?.description)!])
                    }
                }
            }
        }
        task.resume()
    }
}
