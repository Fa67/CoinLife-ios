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
import ZAlertView

class candle: UIViewController  {
    var check = 0
    @IBOutlet var webView: UIWebView!
    
    private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }
    private func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        //let value = UIInterfaceOrientation.landscapeLeft.rawValue
        //UIDevice.current.setValue(value, forKey: "orientation")
        
        webView.scrollView.isScrollEnabled = false;
        webView.scrollView.bounces = false;
        
        var coin = table_controller.send_data[0]
        var change = table_controller.send_data[1]
        
        var krw_usd = ""
        if change == "Bithumb"{
            krw_usd = "KRW"
        }
        else if change == "Binance"{
            krw_usd = "USD"
            if coin == "BTC"{
                krw_usd = "USDT"
            }
        }
        else if change == "BitTrex"{
            change = "Bittrex"
            krw_usd = "USDT"
        }
        else if change == "Poloniex"{
            krw_usd = "USDT"
        }
        else if change == "Coinone"{
            krw_usd = "KRW"
        }
        else if change == "Korbit"{
            krw_usd = "KRW"
        }
        else if change == "Coinnest"{
            krw_usd = "KRW"
        }
        else if change == "BitFinex"{
            change = "Bitfinex"
            krw_usd = "USD"
            if coin == "QTUM"{
                coin = "QTM"
            }
        }
        else if change == "BitFlyer"{
            change = "bitFlyer"
            krw_usd = "JPY"
        }
        else if change == "Cexio"{
            change = "CEXIO"
            krw_usd = "USD"
        }
        else if change == "Gateio"{
            change = "GATEIO"
            krw_usd = "USD"
        }
        else if change == "Upbit"{
            krw_usd = "KRW"
        }
        else if change == "Yobit"{
            krw_usd = "USD"
        }
        else if change == "Upbit"{
            krw_usd = "KRW"
        }
        
        //change = change.uppercased()
        self.title = change + ":" + coin + krw_usd
        let js = "<!-- TradingView Widget BEGIN --><script type=\"text/javascript\" src=\"https://s3.tradingview.com/tv.js\"></script><script type=\"text/javascript\">new TradingView.widget({\"autosize\": true,\"symbol\": \"" + change + ":" + coin + krw_usd + "\",\"interval\": \"3\",\"timezone\": \"Asia/Seoul\",\"theme\": \"Light\",\"style\": \"1\",\"locale\": \"kr\",\"toolbar_bg\": \"#f1f3f6\",\"enable_publishing\": false,\"hide_top_toolbar\": false,\"save_image\": false, \"studies\": [\"BB@tv-basicstudies\"],\"hideideas\": true});</script><!-- TradingView Widget END -->"
        //ViewControllerUtils().showActivityIndicator(uiView: self.view)
        self.webView.loadHTMLString(js, baseURL: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if check == 1{
            let dialog = ZAlertView(title: "오류", message: "지원하지 않은 차트 입니다.", closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
    }
    
}




