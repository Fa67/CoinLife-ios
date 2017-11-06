//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bitflyer {
    static var is_doing = false
    
    init() {
        if (!ticker_bitflyer.is_doing){
            //ticker_bitflyer.is_doing = true
            if coin_kind.count != 0{
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "BitFlyer"){
                        let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=btc_usd")
                        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                            guard let data = data, error == nil else { return }
                            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                            
                            var usbtc = Float(0)
                            if (text.contains("\"ltp\":") && coin_kind[i][0] == "BTC"){
                                coin_kind[i][2] = text.components(separatedBy: "\"ltp\":")[1].components(separatedBy: ",")[0]
                                coin_kind[i][3] = "미지원"
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)!))
                                usbtc = Float(coin_kind[i][2])!
                            }else if(text.contains("\"ltp\":")){

                                let btc_tmp = Float(text.components(separatedBy: "\"ltp\":")[1].components(separatedBy: ",")[0])
                                let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=" + coin_kind[i][0].lowercased() + "_btc")
                                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                                    guard let data = data, error == nil else { return }
                                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                                    //print(text)
                                    if (text.contains("\"ltp\":")){
                                        coin_kind[i][2] = text.components(separatedBy: "\"ltp\":")[1].components(separatedBy: ",")[0]
                                        coin_kind[i][3] = "미지원"
                                        coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(table_controller.usd)! * Float(btc_tmp!)))
                                        if primium_change == "BitFlyer"{
                                           
                                        }
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
                            
                           //ticker_bitflyer.is_doing = false
                            
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



