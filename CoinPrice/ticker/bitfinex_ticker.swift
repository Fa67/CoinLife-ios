//
//  bitfinex_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func bitfinex() {
    if coin_kind.count != 0{
        var whole_str = "fUSD"
        
        for i in 0...coin_kind.count - 1 {
            if ( coin_kind[i][1] == "BitFinex") || !(whole_str.contains("t" + coin_kind[i][0] + "USD") && primium_change == "Bitfinex" ){
                //print(coin_kind[i][0])
                if (coin_kind[i][0] == "QTUM"){
                    //whole_str = whole_str + ",t" + "QTM" + "USD"
                }else if(coin_kind[i][0] == "DASH"){
                    //whole_str = whole_str + ",t" + "DSH" + "USD"
                }else if(coin_kind[i][0] == "IOTA"){
                    //whole_str = whole_str + ",t" + "IOT" + "USD"
                }else if(coin_kind[i][0] == "MIOTA"){
                    //whole_str = whole_str + ",t" + "IOT" + "USD"
                }else if(coin_kind[i][0] == "BCH"){
                    //whole_str = whole_str + ",t" + "BAB" + "USD"
                }else{
                    //whole_str = whole_str + ",t" + coin_kind[i][0] + "USD"
                }
                whole_str = whole_str + ",t" + coin_kind[i][0] + "USD"
            }
        }
        
        let url = URL(string: "https://api.bitfinex.com/v2/tickers?symbols=" + whole_str)
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            
            if primium_change == "Bitfinex"{
                primium = []
            }
            
            //var coin_cnt = whole_str.components(separatedBy: ",")
            for i in 0...coin_kind.count - 1 {
                
                let coin_tmp = coin_kind[i][0]
                if (coin_kind[i][0] == "QTUM"){
                    //coin_tmp = "QTM"
                }else if(coin_kind[i][0] == "DASH"){
                    //coin_tmp = "DSH"
                }else if(coin_kind[i][0] == "BCC"){
                    //coin_tmp = "BCH"
                }else if(coin_kind[i][0] == "MIOTA"){
                    //coin_tmp = "IOT"
                }else if(coin_kind[i][0] == "BCH"){
                    //coin_tmp = "BAB"
                }else if(coin_kind[i][0] == "IOTA"){
                    //coin_tmp = "IOT"
                }
                
                if ( coin_kind[i][1] == "BitFinex"){
                    if (text.contains("\"t" + coin_tmp + "USD\"")){
                        let lets_text = text.components(separatedBy: "\"t" + coin_tmp + "USD\"")[1]
                        coin_kind[i][2] = lets_text.components(separatedBy: ",")[7]
                        coin_kind[i][3] = lets_text.components(separatedBy: ",")[6]
                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)!))//달러 적용 현재가
                        if primium_change == "Bitfinex"{
                            primium.append([coin_kind[i][0].uppercased(),coin_kind[i][2]])
                        }
                        
                        let tmp = round(Float(coin_kind[i][3])! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                        if(tmp > 0) {
                            coin_kind[i][3] = ( "+" + String(tmp))
                        }else{
                            coin_kind[i][3] = ( String(tmp))
                        }
                        coin_kind[i][5] = ("USD")
                        coin_kind[i][6] = lets_text.components(separatedBy: ",")[8]
                        
                    }else if (text.contains("\"error\", 11010")) {
                        coin_kind[i][2] = "ip"
                        coin_kind[i][3] = "ip"
                    }else {
                        coin_kind[i][2] = "미지원"
                        coin_kind[i][3] = "미지원"
                    }
                }
                if primium_change == "Bitfinex"{
                    if !(primium.contains {$0.contains(coin_tmp)}){
                        if (text.contains("\"t" + coin_tmp + "USD\"")){
                            let lets_text = text.components(separatedBy: "\"t" + coin_tmp + "USD\"")[1]
                            var tmppp = lets_text.components(separatedBy: ",")[7]
                            tmppp = String(Int(Float(tmppp)! * Float(table_controller.usd)!))//달러 적용 현재가
                            primium.append([coin_kind[i][0].uppercased(),tmppp])
                            
                        }
                    }
                }
            }
        }
        task.resume()
    }
}
