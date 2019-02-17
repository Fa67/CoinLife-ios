//
//  bithumb_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func bithumb() {
    if coin_kind.count != 0{
        let url = URL(string: "https://api.bithumb.com/public/ticker/All")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            if !(text.contains("status\":\"0000\"")){return}
            for i in 0...coin_kind.count - 1 {
                if coin_kind[i][1] == "Bithumb" && text.contains(coin_kind[i][0]){
                    let main_coin_str = text.components(separatedBy: coin_kind[i][0])[1]
                    coin_kind[i][2] = split(str: main_coin_str,w1: "\"closing_price\":\"",w2: "\"")//현재가
                    let open = split(str: main_coin_str,w1: "\"opening_price\":\"",w2: "\"")//24시간전 가격
                    let before_ = ((Float(coin_kind[i][2])! - Float(open)!) / Float(open)! * 100)//전일대비 비율
                    let del_num = round(before_ * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                    if(del_num > 0) {
                        coin_kind[i][3] = ( "+" + String(del_num))
                    }else{
                        coin_kind[i][3] = ( String(del_num))
                    }
                    coin_kind[i][5] = ( "KRW")
                    coin_kind[i][6] = split(str: main_coin_str,w1: "\"volume_1day\":\"",w2: "\"")
                }else if (coin_kind[i][1] == "Bithumb"){
                    coin_kind[i][2] = "미지원"
                    coin_kind[i][3] = "미지원"
                }
            }
            if primium_change == "Bithumb"{
                primium = []
                for i in 0...coin_kind.count - 1 {
                    if text.contains("\"" + coin_kind[i][0] + "\":"){
                        let tmp = text.components(separatedBy: "\"" + coin_kind[i][0] + "\":")[1]
                        let value = Float(split(str: tmp,w1: "\"closing_price\":\"",w2: "\""))
                        primium.append([coin_kind[i][0].uppercased(),String(Int(value!))])
                    }
                }
            }
        }
        task.resume()
    }
}
