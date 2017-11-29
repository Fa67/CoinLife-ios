//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bitfinex {
    static var is_doing = false
    
    init() {
        if (!ticker_bitfinex.is_doing){
            //ticker_bitfinex.is_doing = true
            if coin_kind.count != 0{
                var whole_str = "fUSD"
                
                
                
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "BitFinex") || !(whole_str.contains("t" + coin_kind[i][0] + "USD") && primium_change == "Bitfinex" ){
                        //print(coin_kind[i][0])
                        if (coin_kind[i][0] == "QTUM"){
                            whole_str = whole_str + ",t" + "QTM" + "USD"
                        }else if(coin_kind[i][0] == "DASH"){
                            whole_str = whole_str + ",t" + "DSH" + "USD"
                        }else{
                           whole_str = whole_str + ",t" + coin_kind[i][0] + "USD"
                        }
                        
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
                        
                        var coin_tmp = coin_kind[i][0]
                        if (coin_kind[i][0] == "QTUM"){
                            coin_tmp = "QTM"
                        }else if(coin_kind[i][0] == "DASH"){
                            coin_tmp = "DSH"
                        }
                        
                        if ( coin_kind[i][1] == "BitFinex"){
                            
                            
                            
                            if (text.contains("\"t" + coin_tmp + "USD\"")){
                                let lets_text = text.components(separatedBy: "\"t" + coin_tmp + "USD\"")[1]
                                coin_kind[i][2] = lets_text.components(separatedBy: ",")[7]
                                coin_kind[i][3] = lets_text.components(separatedBy: ",")[6]
                                //coin_kind[i][2] = self.split(str: text,w1: "\"last_price\":\"",w2: "\"")//현재가격
                                coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                                if primium_change == "Bitfinex"{
                                    primium.append([coin_kind[i][0].uppercased(),coin_kind[i][2]])
                                }
                                
                                let tmp = round(Float(coin_kind[i][3])! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                                if(tmp > 0) {
                                    coin_kind[i][3] = ( "+" + String(tmp))
                                }else{
                                    coin_kind[i][3] = ( String(tmp))
                                }
                                
                                
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
                                    tmppp = String(Int(Float(tmppp)! * Float(TodayViewController.usd)!))//달러 적용 현재가
                                    primium.append([coin_kind[i][0].uppercased(),tmppp])
                                    
                                }
                            }
                        }
                        
                        
                    }
                    
                    
   
                    //ticker_bitfinex.is_doing = false
                }
                task.resume()
            }
            //ticker_bitfinex.is_doing = false
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}
/*
var when =  DispatchTime.now()
when =  when + 1.1 // change 2 to desired number of seconds
DispatchQueue.main.asyncAfter(deadline: when) {
    
}*/
