//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class chart_bitflyer {
    static var is_doing_c = false
    static var is_doing_p = false
    
    init(dateSt:String, dateSt_now:String, periods:String) {
        if (!chart_bitflyer.is_doing_c && !chart_bitflyer.is_doing_p){
            //chart_bitflyer.is_doing_c = true
            //chart_bitflyer.is_doing_p = true
            
            
            
            
            var url2:URL
            url2 = URL(string: "https://api.cryptowat.ch/markets/bitflyer/" + table_controller.send_data[0] + "jpy/ohlc?after=" + dateSt + "&before=" + dateSt_now + "&periods=" + periods  )!
            let task2 = URLSession.shared.dataTask(with: url2 as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                tmppp = text
                chart_bitflyer.is_doing_c = false
            }
            task2.resume()
            
           
            
            let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=btc_usd")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                
                if (text.contains("\"ltp\":") && table_controller.send_data[0] == "BTC"){
                    dataa[0] = text.components(separatedBy: "\"ltp\":")[1].components(separatedBy: ",")[0]
                    dataa[1] = "미지원"
                    dataa[2] = "미지원"
                    dataa[3] = "미지원"
                    dataa[4] = "미지원"
                    dataa[5] = text.components(separatedBy: "\"volume\":")[1].components(separatedBy: ",")[0]
                    dataa[0] = String(Int(Float(dataa[0])! * Float(table_controller.usd)!))
                }else if(text.contains("\"ltp\":")){
                    
                    let btc_tmp = Float(text.components(separatedBy: "\"ltp\":")[1].components(separatedBy: ",")[0])
                    let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=" + table_controller.send_data[0].lowercased() + "_btc")
                    let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                        guard let data = data, error == nil else { return }
                        let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                        //print(text)
                        if (text.contains("\"ltp\":")){
                            dataa[0] = text.components(separatedBy: "\"ltp\":")[1].components(separatedBy: ",")[0]
                            dataa[1] = "미지원"
                            dataa[2] = "미지원"
                            dataa[3] = "미지원"
                            dataa[4] = "미지원"
                            dataa[5] = text.components(separatedBy: "\"volume\":")[1].components(separatedBy: ",")[0]
                            dataa[0] = String(Int(Float(dataa[0])! * Float(table_controller.usd)! * Float(btc_tmp!)))
                        }else {
                            dataa[0] = "미지원"
                            dataa[1] = "미지원"
                            dataa[2] = "미지원"
                            dataa[3] = "미지원"
                            dataa[4] = "미지원"
                            dataa[5] = "미지원"
                        }
                        
                        
                    }
                    task.resume()
                }
                else {
                    dataa[0] = "미지원"
                    dataa[1] = "미지원"
                    dataa[2] = "미지원"
                    dataa[3] = "미지원"
                    dataa[4] = "미지원"
                    dataa[5] = "미지원"
                }
                
                chart_bitflyer.is_doing_p = false
                
            }
            task.resume()
            
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}










