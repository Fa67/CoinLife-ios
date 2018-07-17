//
//  loading.swift
//  CoinPrice
//
//  Created by User on 2018. 4. 22..
//  Copyright © 2018년 jungho. All rights reserved.
//

import UIKit
import Foundation
class loading: UITabBarController  {
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //init_()
        
        let time = DispatchTime.now() + .seconds(0)
        DispatchQueue.main.asyncAfter(deadline: time) {
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "gogo")
            self.present(nextView, animated: false, completion: nil)
        }
        
        /*let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()
        present(nextView!, animated: true, completion: nil)*/
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
        
        url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?pkid=141&key=exchangeApiNationOnly&where=nexearch&q=cny&u1=keb&u7=0&u3=CNY&u4=KRW&u5=info&u2=1")
        task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if (parset?.contains("\"price\" : \""))!{
                table_controller.cny_r = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
                let gettext2 = String(describing: self.defaults!.object(forKey: "money_v") ?? "")
                if gettext2 == "" || gettext2 == "0"{
                    table_controller.cny = table_controller.cny_r
                }else{
                    let gettext = String(describing: self.defaults!.object(forKey: "money_cny_f") ?? "")
                    if gettext == ""{
                        table_controller.cny = table_controller.cny_r
                        table_controller.cny_f = table_controller.cny_r
                    }else{
                        table_controller.cny = gettext
                        table_controller.cny_f = gettext
                    }
                }
            }
        }
        task.resume()
        
        /*
         url = URL(string: "http://hangang.dkserver.wo.tc")
         task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
         guard let data = data, error == nil else { return }
         let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
         if (parset?.contains("\"temp\":\""))!{
         table_controller.water = (parset?.components(separatedBy: "\"temp\":\"")[1].components(separatedBy: "\",")[0])!
         }
         }
         task.resume()*/
        
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
                let symbol = self.split2(str: cnt![i],w1: "\"symbol\": \"", w2: "\"")
                let vol = self.split2(str: cnt![i],w1: "\"24h_volume_usd\": \"", w2: "\"")
                let price = self.split2(str: cnt![i],w1: "\"price_usd\": \"", w2: "\"")
                let change = self.split2(str: cnt![i],w1: "\"percent_change_24h\": \"", w2: "\"")
                
                get_market.append([name,vol,price,change,symbol]);
            }
        }
        task2.resume()
        
        /*
         let urll2 = URL(string: "https://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote")
         let taskk2 = URLSession.shared.dataTask(with: urll2! as URL) { data, response, error in
         guard let data = data, error == nil else { return }
         let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
         if (parset?.contains("<field name=\"name\">USD/KRW</field>"))!{
         let tmp_usd = parset?.components(separatedBy: "<field name=\"name\">USD/KRW</field>")[1]
         if (parset?.contains("<field name=\"price\">"))!{
         let tmp_usd2 = tmp_usd?.components(separatedBy: "<field name=\"price\">")[1]
         table_controller.usd = (tmp_usd2?.components(separatedBy: "</field>")[0])!
         }
         }
         if (parset?.contains("<field name=\"name\">USD/JPY</field>"))!{
         let tmp_jpy = parset?.components(separatedBy: "<field name=\"name\">USD/JPY</field>")[1]
         if (parset?.contains("<field name=\"price\">"))!{
         let tmp_jpy2 = tmp_jpy?.components(separatedBy: "<field name=\"price\">")[1]
         table_controller.jpy = (Float(table_controller.usd)! / Float((tmp_jpy2?.components(separatedBy: "</field>")[0])!)! * 100).description
         }
         }
         if (parset?.contains("<field name=\"name\">USD/CNY</field>"))!{
         let tmp_jpy = parset?.components(separatedBy: "<field name=\"name\">USD/CNY</field>")[1]
         if (parset?.contains("<field name=\"price\">"))!{
         let tmp_cny2 = tmp_jpy?.components(separatedBy: "<field name=\"price\">")[1]
         table_controller.cny = (Float(table_controller.usd)! / Float((tmp_cny2?.components(separatedBy: "</field>")[0])!)!).description
         }
         }
         }
         taskk2.resume()*/
        
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
        
        url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/crix-production/crix_master")
        let task12 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            up_list = parset! as String
        }
        task12.resume()
    }
    
    func split2(str:String,w1:String,w2:String) -> String{
        var tmp = ""
        if (str.contains(w1)){
            tmp = str.components(separatedBy: w1)[1]
        }else{
            return "0"
        }
        if (tmp.contains(w2)){
            tmp = tmp.components(separatedBy: w2)[0]
        }else{
            return "-0"
        }
        return tmp
    }
}
