//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class chart_huobi {
    static var is_doing_c = false
    static var is_doing_p = false
    
    init(dateSt:String, dateSt_now:String, periods:String) {
        if (!chart_huobi.is_doing_c && !chart_huobi.is_doing_p){
            //chart_huobi.is_doing_c = true
            //chart_huobi.is_doing_p = true
            
            
            
            var url2:URL
            url2 = URL(string: "https://api.cryptowat.ch/markets/huobi/" + table_controller.send_data[0] + "cny/ohlc?after=" + dateSt + "&before=" + dateSt_now + "&periods=" + periods  )!
            let task2 = URLSession.shared.dataTask(with: url2 as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                tmppp = text
                chart_huobi.is_doing_c = false
            }
            task2.resume()
            
            let url = URL(string: "http://api.huobi.com/staticmarket/ticker_" + table_controller.send_data[0].lowercased() + "_json.js")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                //print(text)
                if (text.contains("\"last\":")){
                    dataa[0] = text.components(separatedBy: "\"last\":")[1].components(separatedBy: ",")[0]

                    dataa[3] = text.components(separatedBy: "\"high\":")[1].components(separatedBy: ",")[0]
                    dataa[3] = String(Int(Float(table_controller.cny)! * Float(dataa[3])!))
                    dataa[4] = text.components(separatedBy: "\"low\":")[1].components(separatedBy: ",")[0]
                    dataa[4] = String(Int(Float(table_controller.cny)! * Float(dataa[4])!))
                    dataa[5] = text.components(separatedBy: "\"vol\":")[1].components(separatedBy: ",")[0]
                    
                    dataa[2] = text.components(separatedBy: "\"open\":")[1].components(separatedBy: ",")[0]
                    let before_ = ((Float(dataa[0])! - Float(dataa[2])!) / Float(dataa[0])! * 100)//전일대비 비율
                    let tmp = round(Float(before_) * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                    
                    if(tmp > 0) {
                        dataa[1] = ( "+" + String(tmp))
                    }else{
                        dataa[1] = ( String(tmp))
                    }
                    dataa[0] = String(Int(Float( dataa[0])! * Float(table_controller.cny)!))
                    dataa[2] = String(Int(Float(table_controller.cny)! * Float(dataa[2])!))
                    
                }else {
                    dataa[0] = "미지원"
                    dataa[1] = "미지원"
                    dataa[2] = "미지원"
                    dataa[3] = "미지원"
                    dataa[4] = "미지원"
                    dataa[5] = "미지원"
                }
                chart_huobi.is_doing_p = false
                
            }
            task.resume()
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}








