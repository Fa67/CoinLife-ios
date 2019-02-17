//
//  loading.swift
//  CoinPrice
//
//  Created by User on 2018. 4. 22..
//  Copyright © 2018년 jungho. All rights reserved.
//

import UIKit
import Foundation
import ZAlertView


var korbit_ex = "" , bitfinex_ex = "" , bittrex_ex = "" , binance_ex = "" , bithumb_ex = "" , poloniex_ex = ""
var up_list = ""
var notice = "/"
var coin_kind: [[String]] = []//여기에 걍 막 저장
var coin_kind_wallet : [[String]] = []
var section_change: [String] = []//거래소 리스트
var section_change2 : [[[String]]] = []//거래소 별로 저장
var primium: [[String]] = [] //프리미엄 싹다 저장
var check_upbit = 0

var primium_change = ""
var primium_change_tmp = ""
var kind_price = ""

class init_loading: UITabBarController  {

    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    
    //10초에 한번씩 스캔
    var timer:Timer! 
    var timeCount:Float = 7 //5초마다 갱신
    @objc func timerDidFire(){
        scan_all_ticker()
        timeCount = 7.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_()
        self.load_arr()
        self.load_primium()
        self.load_kind()
        scan_all_ticker()
        
        ZAlertView.positiveColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
        ZAlertView.negativeColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 7.0, target: self, selector: #selector(self.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    //코인정보 모든 저장불러오기
    func load_arr() {
        var coin_kind_tmp: [[String]] = []
        var defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        var gettext = String(describing: defaults!.object(forKey: "arr") ?? "")
        if gettext == ""{return}
        var tmp: [String] = []
        tmp = gettext.components(separatedBy: "#")
        //print(tmp)
        for i in 0...tmp.count - 2 {
            var tmpp_data = tmp[i].components(separatedBy: "@")
            if tmpp_data.count == 3{
                if (tmpp_data[2] == "wallet"){
                    //coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---","wallet","---","---"])
                }else{
                    coin_kind_tmp.append([tmpp_data[0], tmpp_data[1],"---","---","---","---","---"])
                }
            }else{
                coin_kind_tmp.append([tmpp_data[0], tmpp_data[1],"---","---","---","---","---"])
            }
        }
        var for_t = tmp.count - 2
        for _ in 0...tmp.count - 2 {
            var c_tmp = "---"
            if (coin_kind_tmp.count > 0){
                c_tmp = coin_kind_tmp[0][1]
            }
            for ii in 0...tmp.count - 2 {
                if (ii <= for_t){
                    if (c_tmp == coin_kind_tmp[ii][1]){
                        //print(coin_kind_tmp[ii])
                        coin_kind.append(coin_kind_tmp[ii])
                    }
                }
            }
            
            var tmp_v = 0
            for var ii in 0...tmp.count - 2 {
                ii = ii - tmp_v
                if (ii <= for_t){
                    if (c_tmp == coin_kind_tmp[ii][1]){
                        //print("-")
                        //print(coin_kind_tmp[ii])
                        coin_kind_tmp.remove(at: ii)
                        for_t = for_t - 1
                        tmp_v = tmp_v + 1
                    }
                }
            }
            //print("\n")
            
        }
        //print(coin_kind)
        
        defaults = UserDefaults(suiteName: "group.jungcode.coin_wallet")
        defaults?.synchronize()
        gettext = String(describing: defaults!.object(forKey: "arr") ?? "")
        if gettext == ""{return}
        tmp = gettext.components(separatedBy: "#")
        for i in 0...tmp.count - 2 {
            var tmpp_data = tmp[i].components(separatedBy: "@")
            //coin_kind_wallet.append([tmpp_data[0], tmpp_data[1],tmpp_data[2],"---",])
            coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---","wallet","---","---"])
        }
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }
    
    func load_kind() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "kind") ?? "")
        do {
            kind_price=gettext
        }
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }
    
    func load_primium() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "primium") ?? "")
        do {
            primium_change=gettext
        }
    }
    
    func init_(){
        var url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?pkid=141&key=exchangeApiNationOnly&where=nexearch&q=usd&u1=keb&u7=0&u3=USD&u4=KRW&u5=info&u2=1")
        var task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if (parset?.contains("\"price\" : \""))!{
                table_controller.usd_r = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
                let gettext2 = String(describing: self.defaults!.object(forKey: "money_v") ?? "")
                if gettext2 == "" || gettext2 == "0"{
                    table_controller.usd = table_controller.usd_r
                }else{
                    let gettext = String(describing: self.defaults!.object(forKey: "money_usd_f") ?? "")
                    if gettext == ""{
                        table_controller.usd = table_controller.usd_r
                        table_controller.usd_f = table_controller.usd_r
                    }else{
                        table_controller.usd = gettext
                        table_controller.usd_f = gettext
                    }
                }
            }
        }
        task.resume()
        
        url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?pkid=141&key=exchangeApiNationOnly&where=nexearch&q=jpy&u1=keb&u7=0&u3=JPY&u4=KRW&u5=info&u2=100")
        task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if (parset?.contains("\"price\" : \""))!{
                table_controller.jpy_r = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
                let gettext2 = String(describing: self.defaults!.object(forKey: "money_v") ?? "")
                if gettext2 == "" || gettext2 == "0"{
                    table_controller.jpy = table_controller.jpy_r
                }else{
                    let gettext = String(describing: self.defaults!.object(forKey: "money_jpy_f") ?? "")
                    if gettext == ""{
                        table_controller.jpy = table_controller.jpy_r
                        table_controller.jpy_f = table_controller.jpy_r
                    }else{
                        table_controller.jpy = gettext
                        table_controller.jpy_f = gettext
                    }
                }
            }
        }
        task.resume()
        
        url = URL(string: "https://coinmarketcap.com/")
        let task3 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            find_num = parset! as String
        }
        task3.resume()
        
        url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?start=0&limit=100")
        let task2 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            var cnt = parset?.components(separatedBy: "\"id\": \"")
            for i in 1...(cnt?.count)! - 2 {
                //print(cnt![i])
                let name = cnt![i].components(separatedBy: "\"")[0]
                let symbol = split_s(str: cnt![i],w1: "\"symbol\": \"", w2: "\"")
                let vol = split_s(str: cnt![i],w1: "\"24h_volume_usd\": \"", w2: "\"")
                let price = split_s(str: cnt![i],w1: "\"price_usd\": \"", w2: "\"")
                let change = split_s(str: cnt![i],w1: "\"percent_change_24h\": \"", w2: "\"")
                
                get_market.append([name,vol,price,change,symbol]);
            }
        }
        task2.resume()
        
        url = URL(string: "https://coinmarketcap.com/ko/exchanges/bitfinex/")
        let task5 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            bitfinex_ex = parset! as String
        }
        task5.resume()
        url = URL(string: "https://coinmarketcap.com/ko/exchanges/bittrex/")
        let task6 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            bittrex_ex = parset! as String
        }
        task6.resume()
        url = URL(string: "https://coinmarketcap.com/ko/exchanges/poloniex/")
        let task7 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            poloniex_ex = parset! as String
        }
        task7.resume()
        url = URL(string: "https://coinmarketcap.com/ko/exchanges/bithumb/")
        let task8 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            bithumb_ex = parset! as String
        }
        task8.resume()
        url = URL(string: "https://coinmarketcap.com/ko/exchanges/binance/")
        let task9 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            binance_ex = parset! as String
        }
        task9.resume()
        url = URL(string: "https://coinmarketcap.com/ko/exchanges/korbit/")
        let task11 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            korbit_ex = parset! as String
        }
        task11.resume()
        
        url = URL(string: "https://api.upbit.com/v1/market/all")
        let task12 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            up_list = parset! as String
        }
        task12.resume()
    }
    
    
}
