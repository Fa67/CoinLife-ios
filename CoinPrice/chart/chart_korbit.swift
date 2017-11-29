//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class chart_korbit {
    static var is_doing_c = false
    static var is_doing_p = false
    
    init(dateSt:String, dateSt_now:String, periods:String) {
        if (!chart_korbit.is_doing_c && !chart_korbit.is_doing_p){
            //chart_korbit.is_doing_c = true
            //chart_korbit.is_doing_p = true
            
            var url2:URL
            url2 = URL(string: "https://api.cryptowat.ch/markets/korbit/" + table_controller.send_data[0] + "krw/ohlc?after=" + dateSt + "&periods=" + periods  )!
            let task2 = URLSession.shared.dataTask(with: url2 as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                tmppp = text
                chart_korbit.is_doing_c = false
            }
            task2.resume()
            
            
            let url = URL(string: "https://api.korbit.co.kr/v1/ticker/detailed?currency_pair=" + table_controller.send_data[0].lowercased() + "_krw")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                //print(text)
                if (text.contains("\"last\":\"")){
                    dataa[0] = text.components(separatedBy: "\"last\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[1] = text.components(separatedBy: "\"changePercent\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[3] = text.components(separatedBy: "\"high\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[4] = text.components(separatedBy: "\"low\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[5] = text.components(separatedBy: "\"volume\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[2] = Int(Float(dataa[0])! - Float(dataa[0])! * 0.01 * Float(dataa[1])!).description
                    let tmp = round(Float(dataa[1])! * pow(10.0, Float(2))) / pow(10.0, Float(2))
                    if(tmp > 0) {
                        dataa[1] = ( "+" + String(tmp))
                    }else{
                        dataa[1] = ( String(tmp))
                    }
                }else{
                    dataa[0] = "미지원"
                    dataa[1] = "미지원"
                    dataa[2] = "미지원"
                    dataa[3] = "미지원"
                    dataa[4] = "미지원"
                    dataa[5] = "미지원"
                }
                chart_korbit.is_doing_p = false
                
            }
            task.resume()
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}






