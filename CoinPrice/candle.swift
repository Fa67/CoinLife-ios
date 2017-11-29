//
//  chart.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 16..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore



class candle: UIViewController  {
    

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        
        
        webView.scrollView.isScrollEnabled = false;
        webView.scrollView.bounces = false;
        
        var coin = table_controller.send_data[0]
        var change = table_controller.send_data[1]
        var krw_usd = ""
        if change == "Bithumb"{
            change = "XCOIN"
            krw_usd = "KRW"
        }
        else if change == "Coinone" || change == "Korbit" || change == "Coinnest"{
            krw_usd = "KRW"
        }
        else if change == "BitTrex" || change == "Poloniex" || change == "BitFinex"{
            krw_usd = "USD"
        }
        else if change == "BitFlyer"{
            krw_usd = "JPY"
        }
        
        change = "BITFINEX"
        krw_usd = "USD"
        if coin == "QTUM"{
            coin = "QTM"
        }
        if coin == "BCC"{
            coin = "BCH"
        }
        
        self.title = "BITFINEX:" + coin + krw_usd
        
        let js = "<!-- TradingView Widget BEGIN --><script type=\"text/javascript\" src=\"https://s3.tradingview.com/tv.js\"></script><script type=\"text/javascript\">new TradingView.widget({\"autosize\": true,\"symbol\": \"" + change + ":" + coin + krw_usd + "\",\"interval\": \"D\",\"timezone\": \"Asia/Seoul\",\"theme\": \"Light\",\"style\": \"1\",\"locale\": \"kr\",\"toolbar_bg\": \"#f1f3f6\",\"enable_publishing\": false,\"hide_top_toolbar\": false,\"save_image\": false,\"hideideas\": true});</script><!-- TradingView Widget END -->"
        
        
        self.webView.loadHTMLString(js, baseURL: nil)
        //webView.evaluateJavaScript(js, completionHandler: nil)
       // webView.stringByEvaluatingJavaScript(from: js)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool){
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
   
    
}




