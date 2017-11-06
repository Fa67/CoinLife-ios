//
//  ticker_bithumb.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 30..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation

class ticker_coinnest {
    static var is_doing = false
    
    init() {
        if (!ticker_coinnest.is_doing){
            //ticker_coinnest.is_doing = true
            if coin_kind.count != 0{
                for i in 0...coin_kind.count - 1 {
                    if ( coin_kind[i][1] == "Coinnest"){
                        
                        let url = URL(string: "https://api.coinnest.co.kr/api/pub/ticker?coin=" + coin_kind[i][0].lowercased())
                        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                            guard let data = data, error == nil else { return }
                            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                            //print(text)
                            //print("코네")
                            if (text.contains("\"last\":")){
                                coin_kind[i][2] = text.components(separatedBy: "\"last\":")[1].components(separatedBy: ",")[0]
                                coin_kind[i][3] = "미지원"
                                
                                if primium_change == "Coinnest"{
                                    primium = []
                                }
                            }else {
                                coin_kind[i][2] = "미지원"
                                coin_kind[i][3] = "미지원"
                            }
                            //ticker_coinnest.is_doing = false
                            
                        }
                        task.resume()
                    }
                }
            }
        }
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
}




