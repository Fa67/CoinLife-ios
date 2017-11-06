//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_huobi {
    static var is_doing = false
    
    init() {
        if (!ticker_huobi.is_doing){
            //ticker_huobi.is_doing = true
            if coin_kind.count != 0{
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "Huobi"){
                        
                        let url = URL(string: "http://api.huobi.com/staticmarket/ticker_" + coin_kind[i][0].lowercased() + "_json.js")
                        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                            guard let data = data, error == nil else { return }
                            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                            //print(text)
                            if (text.contains("\"last\":")){
                                coin_kind[i][2] = text.components(separatedBy: "\"last\":")[1].components(separatedBy: ",")[0]
                                //print(coin_kind[i][2])
                                let open = text.components(separatedBy: "\"open\":")[1].components(separatedBy: ",")[0]
                                //print(open)
                                let before_ = ((Float(coin_kind[i][2])! - Float(open)!) / Float(coin_kind[i][2])! * 100)//전일대비 비율
                                //print(before_)
                                let tmp = round(Float(before_) * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                                
                                if(tmp > 0) {
                                    coin_kind[i][3] = ( "+" + String(tmp))
                                }else{
                                    coin_kind[i][3] = ( String(tmp))
                                }
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.cny)!))
                                if primium_change == "Huobi"{
                                    primium = []
                                }
                            }else {
                                coin_kind[i][2] = "미지원"
                                coin_kind[i][3] = "미지원"
                            }
                            //ticker_huobi.is_doing = false
                            
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




