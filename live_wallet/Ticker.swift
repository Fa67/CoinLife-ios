//
//  Ticker.swift
//  CoinPrice
//
//  Created by User on 2017. 12. 6..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation


class Ticker {
    
    func bithumb() {
        if coin_kind.count != 0{
            let url = URL(string: "https://api.bithumb.com/public/ticker/All")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                if !(text.contains("status\":\"0000\"")){return}
                for i in 0...coin_kind.count - 1 {
                    if coin_kind[i][1] == "Bithumb" && text.contains(coin_kind[i][0]){
                        let main_coin_str = text.components(separatedBy: coin_kind[i][0])[1]
                        coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"closing_price\":\"",w2: "\"")//현재가
                        
                    }else if (coin_kind[i][1] == "Bithumb"){
                        coin_kind[i][2] = "미지원"
                     
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func bitfinex() {
        if coin_kind.count != 0{
            var whole_str = "fUSD"
            
            for i in 0...coin_kind.count - 1 {
                if ( coin_kind[i][1] == "BitFinex") || !(whole_str.contains("t" + coin_kind[i][0] + "USD") ){
                    //print(coin_kind[i][0])
                    if (coin_kind[i][0] == "QTUM"){
                        whole_str = whole_str + ",t" + "QTM" + "USD"
                    }else if(coin_kind[i][0] == "DASH"){
                        whole_str = whole_str + ",t" + "DSH" + "USD"
                    }else if(coin_kind[i][0] == "IOTA"){
                        whole_str = whole_str + ",t" + "IOT" + "USD"
                    }else if(coin_kind[i][0] == "MIOTA"){
                        whole_str = whole_str + ",t" + "IOT" + "USD"
                    }else{
                        whole_str = whole_str + ",t" + coin_kind[i][0] + "USD"
                    }
                    
                }
            }
            
            let url = URL(string: "https://api.bitfinex.com/v2/tickers?symbols=" + whole_str)
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                
               
                
                //var coin_cnt = whole_str.components(separatedBy: ",")
                for i in 0...coin_kind.count - 1 {
                    
                    var coin_tmp = coin_kind[i][0]
                    if (coin_kind[i][0] == "QTUM"){
                        coin_tmp = "QTM"
                    }else if(coin_kind[i][0] == "DASH"){
                        coin_tmp = "DSH"
                    }else if(coin_kind[i][0] == "BCC"){
                        coin_tmp = "BCH"
                    }else if(coin_kind[i][0] == "MIOTA"){
                        coin_tmp = "IOT"
                    }else if(coin_kind[i][0] == "IOTA"){
                        coin_tmp = "IOT"
                    }
                    
                    if ( coin_kind[i][1] == "BitFinex"){
                        if (text.contains("\"t" + coin_tmp + "USD\"")){
                            let lets_text = text.components(separatedBy: "\"t" + coin_tmp + "USD\"")[1]
                            coin_kind[i][2] = lets_text.components(separatedBy: ",")[7]
                        
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                            
                            
                     
                            
                        }else if (text.contains("\"error\", 11010")) {
                            coin_kind[i][2] = "ip"
                    
                        }else {
                            coin_kind[i][2] = "미지원"
                    
                        }
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func coinone() {
        if coin_kind.count != 0{
            let url = URL(string: "https://api.coinone.co.kr/ticker?currency=all")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.ascii.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                if !(text.contains("btc")){return}
                for i in 0...coin_kind.count - 1 {
                    if coin_kind[i][1] == "Coinone" && text.contains("\"" + coin_kind[i][0].lowercased() + "\""){
                        let main_coin_str = text.components(separatedBy: coin_kind[i][0].lowercased())[1]
                        coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")
                       
             
                    }else if (coin_kind[i][1] == "Coinone"){
                        coin_kind[i][2] = "미지원"
                 
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func poloniex() {
        if coin_kind.count != 0{
            let url = URL(string: "https://poloniex.com/public?command=returnTicker")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.ascci.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                if !(text.contains("\"USDT_BTC\"")){return}
                
                let usbtc = Float(self.split(str: text.components(separatedBy: "\"USDT_BTC\"")[1],w1: "\"last\":\"",w2: "\","))
                
                for i in 0...coin_kind.count - 1 {
                    if (coin_kind[i][1] == "Poloniex"){
                        if text.contains("\"USDT_" + coin_kind[i][0] + "\""){
                            let whole_str = text.components(separatedBy: "\"USDT_" + coin_kind[i][0] + "\"")[1]
                            coin_kind[i][2] = self.split(str: whole_str,w1: "\"last\":\"",w2: "\"")
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//현재가 달러 환율 적용
                            
        
                        }
                        else if text.contains("\"BTC_" + coin_kind[i][0] + "\""){
                            let main_coin_str = text.components(separatedBy: "\"BTC_" + coin_kind[i][0] + "\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")
                           
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//현재가 달러 환율 적용
                            
                 
                        }else{
                            coin_kind[i][2] = "미지원"
                      
                        }
                    }
                    
                }
                
            }
            task.resume()
        }
    }
    
    func korbit() {
        if coin_kind.count != 0{
            for i in 0...coin_kind.count - 1 {
                if ( coin_kind[i][1] == "Korbit"){
                    
                    let url = URL(string: "https://api.korbit.co.kr/v1/ticker/detailed?currency_pair=" + coin_kind[i][0].lowercased() + "_krw")
                    let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                        guard let data = data, error == nil else { return }
                        let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                        
                        if (text.contains("\"last\":\"")){
                            coin_kind[i][2] = self.split(str: text,w1: "\"last\":\"",w2: "\"")
                            
                            
                            
                        }else {
                            coin_kind[i][2] = "미지원"
           
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func bitflyer() {
        if coin_kind.count != 0{
            for i in 0...coin_kind.count - 1 {
                if ( coin_kind[i][1] == "BitFlyer"){
                    let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=btc_jpy")
                    let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                        guard let data = data, error == nil else { return }
                        let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                        
                        if (text.contains("\"ltp\":") && coin_kind[i][0] == "BTC"){
                            coin_kind[i][2] = self.split(str: text,w1: "\"ltp\":",w2: ",")
                           
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.jpy)! * 0.01))
                         
                            //usbtc = Float(coin_kind[i][2])!
                        }else if(text.contains("\"ltp\":")){
                            let btc_tmp = Float(self.split(str: text,w1: "\"ltp\":",w2: ","))
                            let url = URL(string: "https://api.bitflyer.jp/v1/ticker?product_code=" + coin_kind[i][0].lowercased() + "_btc")
                            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                                guard let data = data, error == nil else { return }
                                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                                //print(text)
                                if (text.contains("\"ltp\":")){
                                    coin_kind[i][2] = self.split(str: text,w1: "\"ltp\":",w2: ",")
                             
                                    coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.jpy)! * 0.01 * Float(btc_tmp!)))
                                    
                  
                                }else {
                                    coin_kind[i][2] = "미지원"
                                    
                                }
                            }
                            task.resume()
                        }
                        else {
                            coin_kind[i][2] = "미지원"
                           
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func coinnest() {
        if coin_kind.count != 0{
            for i in 0...coin_kind.count - 1 {
                if ( coin_kind[i][1] == "Coinnest"){
                    let url = URL(string: "https://api.coinnest.co.kr/api/pub/ticker?coin=" + coin_kind[i][0].lowercased())
                    let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                        guard let data = data, error == nil else { return }
                        let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                        
                        if (text.contains("\"last\":")){
                            coin_kind[i][2] = self.split(str: text,w1: "\"last\":",w2: ",")
                          
         
                            
                        }else {
                            coin_kind[i][2] = "미지원"
                            
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func bittrex() {
        if coin_kind.count != 0{
            let url = URL(string: "https://www.bittrex.com/api/v1.1/public/getmarketsummaries")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                if !(text.contains("\"USDT-BTC")){return}
                
                let usbtc  = Float(self.split(str: text.components(separatedBy: "\"USDT-BTC")[1],w1: "\"Last\":",w2: ","))
                
                for i in 0...coin_kind.count - 1 {
                    var coin_n_tmp = coin_kind[i][0].uppercased()
                    if coin_n_tmp == "BCH"{
                        coin_n_tmp = "BCC"
                    }
                    if coin_kind[i][1] == "BitTrex"{
                        if text.contains("\"USDT-" + coin_n_tmp + "\""){
                            let main_coin_str = text.components(separatedBy: "\"USDT-" + coin_n_tmp + "\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"Last\":",w2: ",")
                            
                        }
                        else if text.contains("\"BTC-" + coin_n_tmp + "\""){
                            let main_coin_str = text.components(separatedBy: "\"BTC-" + coin_n_tmp + "\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"Last\":",w2: ",")//현재가격
                            
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//달러 적용 현재가
                        
                        }
                        else{
                            coin_kind[i][2] = "미지원"
                          
                        }
                    }
                    
                    
                }
                
            }
            task.resume()
        }
    }
    
    func binance() {
        if coin_kind.count != 0{
            let url = URL(string: "https://api.binance.com/api/v1/ticker/allPrices")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                if !(text.contains("symbol\":\"BTCUSDT\"")){return}
                
                let usbtc  = Float(self.split(str: text.components(separatedBy: "symbol\":\"BTCUSDT\"")[1],w1: "\"price\":\"",w2: "\""))
                
                for i in 0...coin_kind.count - 1 {
                    var coin_n_tmp = coin_kind[i][0].uppercased()
                    if coin_n_tmp == "BCH"{
                        coin_n_tmp = "BCC"
                    }
                    if coin_kind[i][1] == "Binance"{
                        if text.contains("symbol\":\"" + coin_n_tmp + "USDT\""){
                            let main_coin_str = text.components(separatedBy: "symbol\":\"" + coin_n_tmp + "USDT\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"price\":\"",w2: "\"")
                           
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
      
                        }
                        else if text.contains("symbol\":\"" + coin_n_tmp + "BTC\""){
                            let main_coin_str = text.components(separatedBy: "symbol\":\"" + coin_n_tmp + "BTC\"")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"price\":\"",w2: "\"")
                           
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//달러 적용 현재가
       
                            
                        }
                        else{
                            coin_kind[i][2] = "미지원"
                           
                        }
                    }
                    
                    
                }
                
            }
            task.resume()
        }
    }
    
    func gateio() {
        if coin_kind.count != 0{
            let url = URL(string: "http://data.gate.io/api2/1/tickers")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                if !(text.contains("\"btc_usdt\":")){return}
                
                let usbtc  = Float(self.split(str: text.components(separatedBy: "\"btc_usdt\":")[1],w1: "\"last\":",w2: ","))
                
                for i in 0...coin_kind.count - 1 {
                    let coin_n_tmp = coin_kind[i][0].lowercased()
                    if coin_kind[i][1] == "Gateio"{
                        if text.contains("\"" + coin_n_tmp + "_usdt\":"){
                            let main_coin_str = text.components(separatedBy: "\"" + coin_n_tmp + "_usdt\":")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":",w2: ",")
                         
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                   
                        }
                        else if text.contains("\"" + coin_n_tmp + "_btc\":"){
                            let main_coin_str = text.components(separatedBy: "\"" + coin_n_tmp + "_btc\":")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":",w2: ",")
                           
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * usbtc!))//달러 적용 현재가
            
                        }
                        else{
                            coin_kind[i][2] = "미지원"
                         
                        }
                    }
                    
                    
                }
                
            }
            task.resume()
        }
    }
    
    func cexio() {
        if coin_kind.count != 0{
            let url = URL(string: "https://cex.io/api/tickers/USD")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                if !(text.contains("\"pair\":\"BTC:USD\"")){return}
                
                //let usbtc  = Float(self.split(str: text.components(separatedBy: "\"pair\":\"BTC:USD\"")[1],w1: "\"last\":\"",w2: "\""))
                
                for i in 0...coin_kind.count - 1 {
                    let coin_n_tmp = coin_kind[i][0].uppercased()
                    if coin_kind[i][1] == "Cexio"{
                        if text.contains("pair\":\"" + coin_n_tmp + ":USD"){
                            let main_coin_str = text.components(separatedBy: "pair\":\"" + coin_n_tmp + ":USD")[1]
                            coin_kind[i][2] = self.split(str: main_coin_str,w1: "\"last\":\"",w2: "\"")
    
                            coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                      
                        }
                        else{
                            coin_kind[i][2] = "미지원"
        
                        }
                    }
                    
                    
                }
               
            }
            task.resume()
        }
    }
    
    func upbit() {
        if coin_kind.count != 0{
            var whole_str = "CRIX.UPBIT.KRW-BTC"
            
            for i in 0...coin_kind.count - 1 {
                
                if ( (coin_kind[i][1] == "Upbit") ){
                    //print(coin_kind[i][0])
                    //print(whole_str)
                    if ( !(whole_str.contains("CRIX.UPBIT.KRW-" + coin_kind[i][0])) && up_list.contains(coin_kind[i][0] + "/KRW")){
                        whole_str = whole_str + ",CRIX.UPBIT.KRW-" + coin_kind[i][0]
                    }
                }
            }
            
            let url = URL(string: "https://crix-api.upbit.com/v1/crix/recent?codes=" + whole_str)
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                
                print(text)
                
                for i in 0...coin_kind.count - 1 {
                    var coin_tmp = coin_kind[i][0]
                    if (coin_kind[i][0] == "BCH"){
                        coin_tmp = "BCC"
                    }
                    if ( coin_kind[i][1] == "Upbit"){
                        if (text.contains("CRIX.UPBIT.KRW-" + coin_tmp)){
                            let lets_text = text.components(separatedBy: "CRIX.UPBIT.KRW-" + coin_tmp)[1]
                            coin_kind[i][2] = self.split(str: lets_text,w1: "\"tradePrice\":",w2: ".")
           
                            
                            
                        }else if (text.contains("\"error\", 11010")) {
                            coin_kind[i][2] = "ip"
                        
                        }else {
                            coin_kind[i][2] = "미지원"
                    
                        }
                    }
                   
                }
            }
            task.resume()
        }
    }
    
    
    
    func yobit() {
        if coin_kind.count != 0{
            let url = URL(string: "https://yobit.net/api/3/info")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let textt = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                
                var whole_str = "btc_usd"
                
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "Yobit") || !(whole_str.contains(coin_kind[i][0].lowercased() + "_btc") ){
                        if (coin_kind[i][0].lowercased() == "bch"){
                            if textt.contains("\"bcc_btc\""){
                                whole_str = whole_str + "-bcc_btc"
                            }
                            whole_str = whole_str + "-bcc_" + "btc"
                        }else{
                            if textt.contains("\"" + coin_kind[i][0].lowercased() + "_btc\""){
                                whole_str = whole_str + "-" + coin_kind[i][0].lowercased() + "_btc"
                            }
                        }
                    }
                }
                
                let url = URL(string: "https://yobit.net/api/3/ticker/" + whole_str)
                let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    
                   
                    
                    var btc_usd = Float(0)
                    if (text.contains("\"btc_usd\"")){
                        let lets_text = text.components(separatedBy: "\"btc_usd\"")[1]
                        btc_usd = Float(self.split(str: lets_text,w1: "\"last\":",w2: ","))!
                        
                        for i in 0...coin_kind.count - 1 {
                            var coin_tmp = coin_kind[i][0].lowercased()
                            if (coin_tmp == "bch"){
                                coin_tmp = "bcc"
                            }
                            if ( coin_kind[i][1] == "Yobit"){
                                if (text.contains("\"" + coin_tmp + "_usd\"")){
                                    let lets_text = text.components(separatedBy: "\"btc_usd\"")[1]
                                    coin_kind[i][2] = self.split(str: lets_text,w1: "\"last\":",w2: ",")
                                    coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)!))//달러 적용 현재가
                         
                               
                                }else if (text.contains("\"" + coin_tmp + "_btc\"")){
                                    let lets_text = text.components(separatedBy: "\"" + coin_tmp + "_btc\"")[1]
                                    coin_kind[i][2] = self.split(str: lets_text,w1: "\"last\":",w2: ",")
                                    coin_kind[i][2] = String(Int(Float(coin_kind[i][2])! * Float(TodayViewController.usd)! * btc_usd))//달러 적용 현재가
                      
                                    
                                    
                                  
                                    
                                }else if (text.contains("\"error\", 11010")) {
                                    coin_kind[i][2] = "ip"
                                 
                                }else {
                                    coin_kind[i][2] = "미지원"
                                   
                                }
                            }
                            
                        }
                    }
                }
                task.resume()
            }
            task.resume()
        }
    }
    

    func split(str:String,w1:String,w2:String) -> String{
        var tmp = ""
        if (str.contains(w1)){
            tmp = str.components(separatedBy: w1)[1]
        }else{
            return "0"
        }
        if (tmp.contains(w2)){
            tmp = tmp.components(separatedBy: w2)[0]
        }else{
            return "0"
        }
        if (Float(tmp) == nil){
            return "0"
        }
        return tmp
    }
}
