//
//  scan_all.swift
//  CoinPrice
//
//  Created by USER on 06/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

import Foundation

func scan_all_ticker(){
    if !(section_change.count == 0){
        var tmp_str = ""
        for i in 0...section_change.count - 1 {
            if(section_change[i] == "Bithumb" || primium_change == "Bithumb"){tmp_str = tmp_str + "bithumb"}
            if(section_change[i] == "Coinone" || primium_change == "Coinone"){tmp_str = tmp_str + "coinone"}
            if(section_change[i] == "Poloniex" || primium_change == "Poloniex"){tmp_str = tmp_str + "poloniex"}
            if(section_change[i] == "BitTrex" || primium_change == "BitTrex"){tmp_str = tmp_str + "bittrex"}
            if(section_change[i] == "BitFinex" || primium_change == "Bitfinex"){tmp_str = tmp_str + "bitfinex"}
            if(section_change[i] == "Korbit" || primium_change == "Korbit"){tmp_str = tmp_str + "korbit"}
            if(section_change[i] == "Coinnest" || primium_change == "Coinnest"){tmp_str = tmp_str + "coinnest"}
            if(section_change[i] == "BitFlyer" || primium_change == "BitFlyer"){tmp_str = tmp_str + "bitflyer"}
            if(section_change[i] == "Upbit" || primium_change == "Upbit"){tmp_str = tmp_str + "Upbit"}
            if(section_change[i] == "Yobit" || primium_change == "Yobit"){tmp_str = tmp_str + "Yobit"}
            if(section_change[i] == "Binance" || primium_change == "Binance"){tmp_str = tmp_str + "Binance"}
            if(section_change[i] == "Gateio" || primium_change == "Gateio"){tmp_str = tmp_str + "Gateio"}
            if(section_change[i] == "Cexio" || primium_change == "Cexio"){tmp_str = tmp_str + "Cexio"}
        }
        if(tmp_str.contains("bithumb")){bithumb()}
        if(tmp_str.contains("coinone")){coinone()}
        if(tmp_str.contains("poloniex")){poloniex()}
        if(tmp_str.contains("bittrex")){ bittrex()}
        if(tmp_str.contains("bitfinex")){ bitfinex()}
        if(tmp_str.contains("korbit")){ korbit()}
        if(tmp_str.contains("coinnest")){ coinnest()}
        if(tmp_str.contains("bitflyer")){ bitflyer()}
        if(tmp_str.contains("Upbit")){ upbit()}
        //if(tmp_str.contains("Yobit")){ yobit()}
        if(tmp_str.contains("Binance")){ binance()}
        //if(tmp_str.contains("Gateio")){ gateio()}
        //if(tmp_str.contains("Cexio")){ cexio()}
    }
}
