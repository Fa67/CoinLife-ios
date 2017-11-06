//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_bittrex {
    static var is_doing = false
    
    init() {
        if (!ticker_bittrex.is_doing){
            //ticker_bittrex.is_doing = true
            if coin_kind.count != 0{
                let url = URL(string: "https://www.bittrex.com/api/v1.1/public/getmarketsummaries")
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    if !(text.contains("\"USDT-BTC")){return}
                    
                    let usbtc = Float(text.components(separatedBy: "\"USDT-BTC")[1].components(separatedBy: "\"Last\":")[1].components(separatedBy: ",")[0])
                    
                    for i in 0...coin_kind.count - 1 {
                        if coin_kind[i][1] == "BitTrex" && text.contains("\"BTC-" + coin_kind[i][0] + "\""){
                            let main_coin_str = text.components(separatedBy: "\"BTC-" + coin_kind[i][0] + "\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"Last\":",w2: ",")//현재가격
                            let open  = self.split(str: main_coin_str,w1: "\"PrevDay\":",w2: ",")//24시간전
                            let rslt  = ((Float(coin_kind[i][2])! - Float(open)!) / Float(coin_kind[i][2])! * 100)//전일대비
                            let tmp = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                            if(tmp > 0) {
                                coin_kind[i][3] = ( "+" + String(tmp))
                            }else{
                                coin_kind[i][3] = ( String(tmp))
                            }
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//달러 적용 현재가
                        }
                        else if coin_kind[i][1] == "BitTrex" && coin_kind[i][0] == "BTC"{
                            coin_kind[i][2] = (usbtc?.description)!//현재가
                            let open  = self.split(str: text.components(separatedBy: "\"USDT-" + coin_kind[i][0] + "\"")[1],w1: "\"PrevDay\":",w2: ",")//24시간전
                            let rslt  = ((Float(coin_kind[i][2])! - Float(open)!) / Float(coin_kind[i][2])! * 100)//전일대비
                            let tmp = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
                            if(tmp > 0) {
                                coin_kind[i][3] = ( "+" + String(tmp))
                            }else{
                                coin_kind[i][3] = ( String(tmp))
                            }
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                        }else if (coin_kind[i][1] == "BitTrex") {
                            coin_kind[i][2] = "미지원"
                            coin_kind[i][3] = "미지원"
                        }
                        
                    }
                    if primium_change == "BitTrex"{
                        primium = []
                        primium.append(["BTC",String(Int(usbtc! * Float(TodayViewController.usd)!))])
                        for i in 0...coin_kind.count - 1 {
                            if text.contains("\"BTC-" + coin_kind[i][0].uppercased() + "\""){
                                let tmp = text.components(separatedBy: "\"BTC-" + coin_kind[i][0].uppercased() + "\"")[1]
                                //let name = tmp.components(separatedBy: "\":")[0].uppercased()
                                let value = Float(tmp.components(separatedBy: "\"Last\":")[1].components(separatedBy: ",")[0])
                                primium.append([coin_kind[i][0].uppercased(),String(Int(value! * Float(TodayViewController.usd)! * usbtc!))])
                            }
                        }
                    }
                    //ticker_bittrex.is_doing = false
                }
                task.resume()
            }
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}




