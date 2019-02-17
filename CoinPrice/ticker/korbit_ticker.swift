//
//  korbit_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func korbit() {
    if coin_kind.count != 0{
        for i in 0...coin_kind.count - 1 {
            if ( coin_kind[i][1] == "Korbit"){
                
                let url = URL(string: "https://api.korbit.co.kr/v1/ticker/detailed?currency_pair=" + coin_kind[i][0].lowercased() + "_krw")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    
                    if (text.contains("\"last\":\"")){
                        coin_kind[i][2] = split(str: text,w1: "\"last\":\"",w2: "\"")
                        coin_kind[i][3] = split(str: text,w1: "\"changePercent\":\"",w2: "\"")
                        
                        let tmp = round(Float(coin_kind[i][3])! * pow(10.0, Float(2))) / pow(10.0, Float(2))
                        if(tmp > 0) {
                            coin_kind[i][3] = ( "+" + String(tmp))
                        }else{
                            coin_kind[i][3] = ( String(tmp))
                        }
                        coin_kind[i][5] = ("KRW")
                        coin_kind[i][6] = split(str: text,w1: "\"volume\":\"",w2: "\"")
                        if primium_change == "Korbit"{
                            primium = []
                        }
                    }else {
                        coin_kind[i][2] = "미지원"
                        coin_kind[i][3] = "미지원"
                    }
                }
                task.resume()
            }
        }
    }
}
