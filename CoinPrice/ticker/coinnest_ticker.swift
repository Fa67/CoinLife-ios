//
//  coinnest_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func coinnest() {
    if coin_kind.count != 0{
        for i in 0...coin_kind.count - 1 {
            if ( coin_kind[i][1] == "Coinnest"){
                let url = URL(string: "https://api.coinnest.co.kr/api/pub/ticker?coin=" + coin_kind[i][0].lowercased())
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    
                    if (text.contains("\"last\":")){
                        coin_kind[i][2] = split(str: text,w1: "\"last\":",w2: ",")
                        coin_kind[i][3] = "미지원"
                        coin_kind[i][5] = ("KRW")
                        coin_kind[i][6] = split(str: text,w1: "\"vol\":",w2: ",")
                        if primium_change == "Coinnest"{
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
