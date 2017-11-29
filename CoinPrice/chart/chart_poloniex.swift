//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class chart_poloniex {
    static var is_doing_c = false
    static var is_doing_p = false
    
    init(dateSt:String, dateSt_now:String, periods:String) {
        if (!chart_poloniex.is_doing_c && !chart_poloniex.is_doing_p){
            //chart_poloniex.is_doing_c = true
            //chart_poloniex.is_doing_p = true
            let url3:URL
            var url2:URL
            if table_controller.send_data[0] == "BTC"{
                url2 = URL(string: "https://api.cryptowat.ch/markets/poloniex/" + table_controller.send_data[0] + "usdt/ohlc?after=" + dateSt + "&periods=" + periods  )!
                url3 = URL(string: "https://api.cryptowat.ch/markets/poloniex/" + table_controller.send_data[0] + "usdt/orderbook"  )!
            }else{
                url2 = URL(string: "https://api.cryptowat.ch/markets/poloniex/" + table_controller.send_data[0] + "btc/ohlc?after=" + dateSt + "&periods=" + periods  )!
                url3 = URL(string: "https://api.cryptowat.ch/markets/poloniex/" + table_controller.send_data[0] + "btc/orderbook"  )!
            }
            let task2 = URLSession.shared.dataTask(with: url2 as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                tmppp = text
                chart_poloniex.is_doing_c = false
            }
            
            if !order_loading_b && !order_loading_a{
                let task3 = URLSession.shared.dataTask(with: url3 as URL) { data, response, error in
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

            
            let url = URL(string: "https://poloniex.com/public?command=returnTicker")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                let to_find = table_controller.send_data[0]
                
                if !(text.contains("\"USDT_BTC\"")){return}
                
                usbtc = Float(text.components(separatedBy: "\"USDT_BTC\"")[1].components(separatedBy: "\"last\":\"")[1].components(separatedBy: "\"")[0])!
                task2.resume()
                
                if (to_find == "BTC"){
                    dataa[0] = String(Int(Float(table_controller.usd)! * usbtc))
                    let usdt_btc_str = text.components(separatedBy: "\"USDT_BTC")[1]
                    dataa[1] = usdt_btc_str.components(separatedBy: "\"percentChange\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[3] = usdt_btc_str.components(separatedBy: "\"high24hr\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[3] = String(Int(Float(table_controller.usd)! * Float(dataa[3])!))
                    dataa[4] = usdt_btc_str.components(separatedBy: "\"low24hr\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[4] = String(Int(Float(table_controller.usd)! * Float(dataa[4])!))
                    dataa[5] = usdt_btc_str.components(separatedBy: "\"quoteVolume\":\"")[1].components(separatedBy: ".")[0]
                    dataa[2] = Int(Float(dataa[0])! - Float(dataa[0])! * Float(dataa[1])!).description
                    let tmp = round(Float(dataa[1])! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))
                    if(tmp > 0) {
                        dataa[1] = ( "+" + String(tmp))
                    }else{
                        dataa[1] = ( String(tmp))
                    }

                }
                else if text.contains("\"BTC_" + to_find + "\""){
                    let usdt_btc_str = text.components(separatedBy: "\"BTC_" + to_find + "\"")[1]
                    dataa[0] = (usdt_btc_str.components(separatedBy: "\"last\":\"")[1].components(separatedBy: "\"")[0])
                    dataa[0] = String(Int(Float(dataa[0])! * Float(table_controller.usd)! * usbtc))
                    dataa[1] = usdt_btc_str.components(separatedBy: "\"percentChange\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[3] = usdt_btc_str.components(separatedBy: "\"high24hr\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[3] = String(Int(Float(table_controller.usd)! * Float(dataa[3])! * usbtc))
                    dataa[4] = usdt_btc_str.components(separatedBy: "\"low24hr\":\"")[1].components(separatedBy: "\"")[0]
                    dataa[4] = String(Int(Float(table_controller.usd)! * Float(dataa[4])! * usbtc))
                    dataa[5] = usdt_btc_str.components(separatedBy: "\"quoteVolume\":\"")[1].components(separatedBy: ".")[0]
                    dataa[2] = Int(Float(dataa[0])! - Float(dataa[0])! * Float(dataa[1])!).description
                    let tmp = round(Float(dataa[1])! * 100 * pow(10.0, Float(2))) / pow(10.0, Float(2))
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
                chart_poloniex.is_doing_p = false
            }
            task.resume()
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}


