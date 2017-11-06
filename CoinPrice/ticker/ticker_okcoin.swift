//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_okcoin {
    static var is_doing = false
    
    init() {
        if (!ticker_okcoin.is_doing){
            //ticker_okcoin.is_doing = true
            if coin_kind.count != 0{
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "Okcoin"){
                        
                        let url = URL(string: "https://www.okcoin.com/api/v1/ticker.do?symbol=" + coin_kind[i][0].lowercased() + "_usd")
                        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                            guard let data = data, error == nil else { return }
                            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                            //print(text)
                            if (text.contains("\"last\":\"")){
                                coin_kind[i][2] = text.components(separatedBy: "\"last\":\"")[1].components(separatedBy: "\"")[0]
                                coin_kind[i][3] = "미지원"
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)!))
                                if primium_change == "Okcoin"{
                                    primium = []
                                }
                            }else {
                                coin_kind[i][2] = "미지원"
                                coin_kind[i][3] = "미지원"
                            }
                            //ticker_okcoin.is_doing = false
                            
                        }
                        task.resume()
                    }
                }
            }
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}




