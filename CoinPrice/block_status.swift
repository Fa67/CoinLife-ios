//
//  block_status.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 25..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import Foundation
import NVActivityIndicatorView
import ZAlertView

var find_num = ""
var get_market : [[String]] = []

class coincell3: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var coin_image: UIImageView!
}

class market: UITableViewCell {
    @IBOutlet var wait: UILabel!
    @IBOutlet var vol: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var change: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var coin_img: UIImageView!
    @IBOutlet var chart: UIImageView!
    @IBOutlet var change2: UIButton!
}

class block_status: UITableViewController , NVActivityIndicatorViewable{
    var check =  [Int](repeating:0, count: 100)
    var docsurl : URL! = nil
    var is_scroll = 0
    let images = ["btc","bch","eth","etc","ltc","dash","xmr","zec"]
    
    static var data: [[String]] = [["BTC","---","---"],["BCH","---","---"],["ETH","---","---"],
    ["ETC","---","---"],["LTC","---","---"],["DASH","---","---"],
    ["XMR","---","---"],["ZEC","---","---"]]
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var total_m: UILabel!
    @IBOutlet var total_b: UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func viewWillAppear(_ animated: Bool){
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
    
    func split2(str:String,w1:String,w2:String) -> String{
        var tmp = ""
        if (str.contains(w1)){
            tmp = str.components(separatedBy: w1)[1]
        }else{
            return "---"
        }
        if (tmp.contains(w2)){
            tmp = tmp.components(separatedBy: w2)[0]
        }else{
            return "---"
        }
        if (Float(tmp) == nil){
            //return "---"
        }
        return tmp
    }
    
    func coma(str:String) ->String{
        var comback = ""
        var tmpp = str
        if tmpp.contains("."){
            comback = tmpp.components(separatedBy: ".")[1]
            tmpp = tmpp.components(separatedBy: ".")[0]
        }
        var price_tmp = tmpp
        var made_price = ""
        while price_tmp.count >= 3{
            let str_cnt = price_tmp.count
            //let back = String(price_tmp[price_tmp.index(price_tmp.endIndex, offsetBy: -3)...])
            let back = price_tmp.substring(from: price_tmp.index(price_tmp.endIndex, offsetBy: -3))
            //price_tmp = String(price_tmp[price_tmp.index(price_tmp.startIndex, offsetBy: str_cnt - 3)...])
            price_tmp = price_tmp.substring(to: price_tmp.index(price_tmp.startIndex, offsetBy: str_cnt-3))
            if (made_price == ""){
                made_price = back
            }else{
                made_price = back + "," + made_price
            }
        }
        if !(price_tmp.count == 0){
            if (made_price == ""){
                made_price = price_tmp
            }else{
                made_price = price_tmp + "," + made_price
            }
        }
        if comback == ""{
            return made_price
        }else{
            return made_price + "." + comback
        }
    }
    
    @objc func reload(_ button:UIBarButtonItem!){
        for i in 0...6{
            block_status.data[i][1] = "---"
            block_status.data[i][2] = "---"
        }
    }
    
    func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager2 = FileManager.default
        docsurl = try! fileManager2.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/tmp"
        do {
            try fileManager2.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        var dataPath = docsurl.appendingPathComponent("tmp")
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
        dataPath = docsurl.appendingPathComponent("tmp2")
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }

        self.reload(nil)
        tableview.reloadData()
        
        let url = URL(string: "https://api.coinmarketcap.com/v1/global/")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            //print(parset!)
            let total_m_v = self.coma(str: self.split2(str: parset! as String,w1: "\"total_market_cap_usd\": ",w2: ",")) + " $"
            let total_b_v = self.split2(str: parset! as String,w1: "\"bitcoin_percentage_of_market_cap\": ",w2: ",") + " %"
            DispatchQueue.main.async {
                self.total_m.text = total_m_v
                self.total_b.text = total_b_v
            }
        }
        task.resume()
    }
    
    //클릭 시
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")//print("row: \(indexPath.row)")
        var info = ""
        
        //print("https://api.coinmarketcap.com/v1/ticker/" + get_market[indexPath.row][0])
        let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/" + get_market[indexPath.row][0])
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(parset!)
            info = info + "현재 가격: " + self.coma(str: self.split2(str: parset! as String,w1: "\"price_usd\": \"",w2: "\"")) + "$"
            info = info + "\n거래량: " + self.coma(str: self.split2(str: parset! as String,w1: "\"24h_volume_usd\": \"",w2: "\"")) + "$"
            info = info + "\n시가 총액: " + self.coma(str: self.split2(str: parset! as String,w1: "\"market_cap_usd\": \"",w2: "\"")) + "$"
            info = info + "\n\n1시간 변동: " + self.split2(str: parset! as String,w1: "\"percent_change_1h\": \"",w2: "\"") + "%"
            info = info + "\n24시간 변동: " + self.split2(str: parset! as String,w1: "\"percent_change_24h\": \"",w2: "\"") + "%"
            info = info + "\n7일 변동: " + self.split2(str: parset! as String,w1: "\"percent_change_7d\": \"",w2: "\"") + "%"
            
            DispatchQueue.main.async {
                for i in 0...7{
                    if get_market[indexPath.row][4].uppercased() == block_status.data[i][0]{
                        info = info + "\n\n블럭 생성 시간: " + block_status.data[i][2]
                        info = info + "\n블럭 수: " + block_status.data[i][1]
                        break
                    }
                }
                let dialog = ZAlertView(title: get_market[indexPath.row][4].uppercased() + " 정보", message: info, closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
                })
                dialog.show()
            }
        }
        task.resume()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //섹션 별 개수 가져오기
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return get_market.count
    }
    
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "market", for: indexPath) as! market

        //코인 이름 저장
        cell.name.text = (indexPath.row + 1).description + ". " + get_market[indexPath.row][4].uppercased()
        
        //달러 계산
        let get_doller = get_market[indexPath.row][2]
        if (get_doller.components(separatedBy: ".")[0].count > 2){
            let doller_ = roundToPlaces(value: Double(get_doller) ?? 0.0,places: 2).description
            cell.change.text = coma(str: doller_.description) + " USD"
        }else{
            let doller_ = roundToPlaces(value: Double(get_doller) ?? 0.0,places: 4).description
            cell.change.text = coma(str: doller_.description) + " USD"
        }
        
        //원화 계산
        let get_krw = (Double(get_market[indexPath.row][2])! * Double(table_controller.usd)!).description
        if (get_krw.components(separatedBy: ".")[0].count > 2){
            let krw_ = get_krw.components(separatedBy: ".")[0]
            cell.price.text = coma(str: krw_.description) + " KRW"
        }else{
            let krw_ = roundToPlaces(value: Double(get_krw) ?? 0.0,places: 2).description
            cell.price.text = coma(str: krw_.description) + " KRW"
        }
        
        cell.vol.text = get_market[indexPath.row][0]
        let change_n = Float(get_market[indexPath.row][3])
        cell.change2.setTitle("   " + (change_n?.description)! + "%   ",for: UIControl.State.normal)
        cell.change2.layer.cornerRadius = 2
        //cell.layer.borderWidth = 1
        if change_n! > Float(0)   {
            cell.change2.backgroundColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.1)
            cell.change2.setTitleColor(UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0),for: UIControl.State.normal)
        }else if  change_n! < Float(0) {
            cell.change2.backgroundColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 0.1)
            cell.change2.setTitleColor(UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0),for: UIControl.State.normal)
        }else{
            cell.change2.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
            cell.change2.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        }
        
        let get_img = load(fileName: "/tmp/" + cell.vol.text! + ".jpg")
        if !(get_img == nil){
            check[indexPath.row] = 1
            cell.chart.image = get_img
        }else{
            cell.chart.image = nil
        }
        
        if find_num.contains(">" + get_market[indexPath.row][4] + "</a></span>"){
            if find_num.components(separatedBy: ">" + get_market[indexPath.row][4] + "</a></span>")[1].contains("s2.coinmarketcap.com/generated/sparklines/web/7d/usd/"){
                let num = find_num.components(separatedBy: ">" + get_market[indexPath.row][4] + "</a></span>")[1].components(separatedBy: "s2.coinmarketcap.com/generated/sparklines/web/7d/usd/")[1].components(separatedBy: ".png")[0]
                let get_img2 = load(fileName: "/tmp2/" + num + "_.png")
                if !(get_img2 == nil){
                    cell.coin_img.image = get_img2
                }else{
                    let sav_name = "/tmp2/" + num + "_.png"
                    let destinationFileUrl = self.docsurl.appendingPathComponent(sav_name)
                    let fileManager = FileManager.default
                    
                    if !fileManager.fileExists(atPath: destinationFileUrl.path) {
                        let fileURL = URL(string: "https://s2.coinmarketcap.com/static/img/coins/64x64/" + num + ".png")
                        print("https://s2.coinmarketcap.com/static/img/coins/64x64/" + num + ".png")
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url:fileURL!)
                        let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                if ((response as? HTTPURLResponse)?.statusCode) != nil {
                                    print("Successfully downloaded. Status code: ")
                                }
                                do {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                } catch ( _) {
                                }
                            }
                        }
                        task2.resume()
                    }
                }
            }else{
                cell.coin_img.image = nil
            }
        }else{
            cell.coin_img.image = nil
        }
        return cell
    }
   
    private func load(fileName: String) -> UIImage? {
        let fileURL = docsurl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            //print("Error loading image : \(error)")
        }
        return nil
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        is_scroll = 1
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.is_scroll = 0
    }
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
