//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class chart_bitfinex {
    static var is_doing_c = false
    static var is_doing_p = false
    
    init(dateSt:String, dateSt_now:String, periods:String) {
        
        if (!chart_bitfinex.is_doing_c && !chart_bitfinex.is_doing_p){
            //chart_bitfinex.is_doing_c = true
            //chart_bitfinex.is_doing_p = true
            
            var coin_tmp2 = table_controller.send_data[0]
            if (table_controller.send_data[0] == "QTUM"){
                //coin_tmp2 = "QTM"
            }
            
            var url2:URL
            url2 = URL(string: "https://api.cryptowat.ch/markets/bitfinex/" + coin_tmp2.lowercased() + "usd/ohlc?after=" + dateSt + "&periods=" + periods  )!
            let task2 = URLSession.shared.dataTask(with: url2 as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                tmppp = text
                chart_bitfinex.is_doing_c = false
            }
            task2.resume()
            
            if !order_loading_b && !order_loading_a{
                var coin_tmp = table_controller.send_data[0]
                if (table_controller.send_data[0] == "QTUM"){
                    //coin_tmp = "QTM"
                }
                let url3 = URL(string: "https://api.cryptowat.ch/markets/bitfinex/" + coin_tmp + "usd/orderbook"  )
                let task3 = URLSession.shared.dataTask(with: url3! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                    if text.contains("\"result\":{\"asks\":"){
                        let tmp1_bid = text.components(separatedBy: "\"asks\":[")[1].components(separatedBy: "\"bids\"")[0]
                        var tmp2_bid = tmp1_bid.components(separatedBy: "[")
                        
                        bid = []
                        ask = []
                        
                        for i in 1...tmp2_bid.count - 1{
                            bid.append(tmp2_bid[i].components(separatedBy: "]")[0])
                            if bidmax < Float(bid[i-1].components(separatedBy: ",")[1])!{
                                bidmax = Float(bid[i-1].components(separatedBy: ",")[1])!
                            }
                            if i == 50 {
                                break
                            }
                        }
                        
                        let tmp1_ask = text.components(separatedBy: "\"bids\":[")[1]
                        var tmp2_ask = tmp1_ask.components(separatedBy: "[")
                        for i in 1...tmp2_ask.count - 1{
                            ask.append(tmp2_ask[i].components(separatedBy: "]")[0])
                            if askmax < Float(ask[i-1].components(separatedBy: ",")[1])!{
                                askmax = Float(ask[i-1].components(separatedBy: ",")[1])!
                            }
                            if i == 50 {
                                break
                            }
                        }
                        
                    }
                    
                }
                task3.resume()
            }
            
            var coin_tmp = table_controller.send_data[0]
            if (table_controller.send_data[0] == "QTUM"){
                coin_tmp = "QTM"
            }else if(table_controller.send_data[0] == "DASH"){
                coin_tmp = "DSH"
            }
            let url = URL(string: "https://api.bitfinex.com/v2/tickers?symbols=t" + coin_tmp + "USD")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                //print(coin_kind[i][0])
                //print(text)
                //print("빗파")
                if (text.contains("\"t" + coin_tmp + "USD\"")){
                    print(text)
                    dataa[0] = text.components(separatedBy: ",")[7]
                    dataa[0] = String(Int(Float(dataa[0])! * Float(table_controller.usd)!))//달러 적용 현재가
                    dataa[1] = text.components(separatedBy: ",")[6]
                    dataa[3] = text.components(separatedBy: ",")[9]
                    dataa[3] = String(Int(Float(table_controller.usd)! * Float(dataa[3])!))
                    dataa[4] = text.components(separatedBy: ",")[10].components(separatedBy: "]")[0]
                    dataa[4] = String(Int(Float(table_controller.usd)! * Float(dataa[4])!))
                    dataa[5] = text.components(separatedBy: ",")[8]

                    dataa[2] = Int(Float(dataa[0])! - Float(dataa[0])! * Float(dataa[1])!).description
                    let tmp = round(Float(dataa[1])! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))//소수점 제거
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
                
                chart_bitfinex.is_doing_p = false
            }
            task.resume()
            
            
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}




