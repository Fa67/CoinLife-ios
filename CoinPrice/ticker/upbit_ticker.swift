//
//  upbit_ticker.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func upbit() {
    if coin_kind.count != 0{
        var whole_str = "CRIX.UPBIT.KRW-BTC"
        
        for i in 0...coin_kind.count - 1 {
            
            if ( (coin_kind[i][1] == "Upbit") || primium_change == "Upbit" ){
                //print(coin_kind[i][0])
                //print(whole_str)
                if ( !(whole_str.contains("CRIX.UPBIT.KRW-" + coin_kind[i][0]))){
                    if (check_upbit == 1){
                        if (up_list.contains("\"KRW-" + coin_kind[i][0] + "\"")){
                            whole_str = whole_str + ",CRIX.UPBIT.KRW-" + coin_kind[i][0]
                            //print(whole_str)
                        }
                    }else{
                        whole_str = whole_str + ",CRIX.UPBIT.KRW-" + coin_kind[i][0]
                    }
                    
                }
            }
        }
        
        //print(whole_str)
        let url = URL(string: "https://crix-api.upbit.com/v1/crix/recent?codes=" + whole_str)
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            //print(text)
            if (text.contains("\"name\":404")){
                check_upbit = 1
            }else{
                if primium_change == "Upbit"{
                    primium = []
                }
                
                for i in 0...coin_kind.count - 1 {
                    let coin_tmp = coin_kind[i][0]
                    if coin_tmp == "BAB"{
                        //coin_tmp = "BCH"
                    }
                    if ( coin_kind[i][1] == "Upbit"){
                        if (text.contains("CRIX.UPBIT.KRW-" + coin_tmp)){
                            let lets_text = text.components(separatedBy: "CRIX.UPBIT.KRW-" + coin_tmp)[1]
                            coin_kind[i][2] = split(str: lets_text,w1: "\"tradePrice\":",w2: ",")
                            coin_kind[i][3] = split(str: lets_text,w1: "\"signedChangeRate\":",w2: "}")
                            
                            if primium_change == "Upbit"{
                                primium.append([coin_kind[i][0].uppercased(),coin_kind[i][2]])
                            }
                            
                            if (Float(coin_kind[i][3]) == nil){
                                continue;
                            }
                            let tmp = round(Float(coin_kind[i][3])! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                            if(tmp > 0) {
                                coin_kind[i][3] = ( "+" + String(tmp))
                            }else{
                                coin_kind[i][3] = ( String(tmp))
                            }
                            coin_kind[i][5] = ("KRW")
                            coin_kind[i][6] = split(str: lets_text,w1: "\"accTradeVolume24h\":",w2: ".")
                            
                        }else if (text.contains("\"error\", ")) {
                            coin_kind[i][2] = "ip"
                            coin_kind[i][3] = "ip"
                        }else {
                            coin_kind[i][2] = "미지원"
                            coin_kind[i][3] = "미지원"
                        }
                    }
                    if primium_change == "Upbit"{
                        if !(primium.contains {$0.contains(coin_tmp)}){
                            if (text.contains("CRIX.UPBIT.KRW-" + coin_tmp)){
                                let lets_text = text.components(separatedBy: "CRIX.UPBIT.KRW-" + coin_tmp)[1]
                                let tmppp = split(str: lets_text,w1: "\"tradePrice\":",w2: ".")
                                primium.append([coin_kind[i][0].uppercased(),tmppp])
                            }
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
}
