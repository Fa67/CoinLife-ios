//
//  TodayViewController.swift
//  live_price
//
//  Created by User on 2017. 11. 4..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import NotificationCenter

var coin_kind: [[String]] = []//여기에 걍 막 저장
var section_change: [String] = []//거래소 리스트
var section_change2 : [[[String]]] = []//거래소 별로 저장
var primium: [[String]] = [] //프리미엄 싹다 저장

var primium_change = ""
var primium_change_tmp = ""
var kind_price = ""
var is_scroll = 0

var up_list = ""

class coincell4: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var before: UILabel!
    @IBOutlet weak var primium: UILabel!
    @IBOutlet var change2: UILabel!
}

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var enablecant = 7
    @IBOutlet weak var reload_text: UIButton!
    @IBOutlet weak var time: UILabel!
    static var usd = "0"//환율
    @IBAction func reload(_ sender: Any) {
        reload_text.isEnabled = false
        list_refresh()
        scan_all()
        if(timer != nil) {timer.invalidate()}
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(TodayViewController.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func timerDidFire(){
        reload_text.setTitle(enablecant.description, for: UIControl.State.normal)
        list_refresh()
        if( enablecant < 0){
            enablecant = 7
            //reload_text.isEnabled = true
            //reload_text.setTitle("새로고침", for: .normal)
            reload_text.setTitle(enablecant.description, for: UIControl.State.normal)
            reload_text.isEnabled = false
            list_refresh()
            scan_all()
            //timer.invalidate()
        }
        enablecant = enablecant - 1
    }
    
    static var jpy = "0"//환율
    var timer3:Timer!
    var timer:Timer!
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?pkid=141&key=exchangeApiNationOnly&where=nexearch&q=usd&u1=keb&u7=0&u3=USD&u4=KRW&u5=info&u2=1")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            TodayViewController.usd = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
        }
        task.resume()
        
        url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?pkid=141&key=exchangeApiNationOnly&where=nexearch&q=jpy&u1=keb&u7=0&u3=JPY&u4=KRW&u5=info&u2=100")
        let task2 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            TodayViewController.jpy = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
        }
        task2.resume()
        
        url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/crix-production/crix_master")
        let task12 = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            up_list = parset! as String
            self.scan_all()
        }
        task12.resume()
        //reload_text.isEnabled = false
        load_arr()
        load_primium()
        load_kind()
        
        list_refresh()
        scan_all()

        reload_text.isEnabled = false
        
        if(timer3 != nil) {timer3.invalidate()}
        timer3 = Timer(timeInterval: 1.0, target: self, selector: #selector(TodayViewController.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer3, forMode: RunLoopMode.commonModes)
        
        tableview.dataSource = self
        tableview.delegate = self
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
       
    }
    
    func scan_all(){
        if !(section_change.count == 0){
            let now = Calendar.current.date(byAdding: .minute, value: 0, to: Date())
            time.text = (now?.description.components(separatedBy: " ")[0])! + " " + (now?.description.components(separatedBy: " ")[1])!
            //print(now?.description)
            
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
                if(section_change[i] == "Yobit" || primium_change == "Yobit"){tmp_str = tmp_str + "Yobit"}
                if(section_change[i] == "Upbit" || primium_change == "Upbit"){tmp_str = tmp_str + "Upbit"}
                if(section_change[i] == "Yobit" || primium_change == "Yobit"){tmp_str = tmp_str + "Yobit"}
                if(section_change[i] == "Binance" || primium_change == "Binance"){tmp_str = tmp_str + "Binance"}
                if(section_change[i] == "Gateio" || primium_change == "Gateio"){tmp_str = tmp_str + "Gateio"}
                if(section_change[i] == "Cexio" || primium_change == "Cexio"){tmp_str = tmp_str + "Cexio"}
            }
            if(tmp_str.contains("bithumb")){Ticker().bithumb()}
            if(tmp_str.contains("coinone")){Ticker().coinone()}
            if(tmp_str.contains("poloniex")){Ticker().poloniex()}
            if(tmp_str.contains("bittrex")){Ticker().bittrex()}
            if(tmp_str.contains("bitfinex")){Ticker().bitfinex()}
            if(tmp_str.contains("korbit")){Ticker().korbit()}
            if(tmp_str.contains("coinnest")){Ticker().coinnest()}
            if(tmp_str.contains("bitflyer")){Ticker().bitflyer()}
            if(tmp_str.contains("Upbit")){Ticker().upbit()}
            if(tmp_str.contains("Yobit")){Ticker().yobit()}
            if(tmp_str.contains("Binance")){Ticker().binance()}
            if(tmp_str.contains("Gateio")){Ticker().gateio()}
            if(tmp_str.contains("Cexio")){Ticker().cexio()}
        }
    }
    
    @objc func timerDidFire3(){
        if is_scroll == 0{
            list_refresh()
            
        }
    }
    
    func list_refresh(){
        add_check_change()
        tableview.reloadData()
        //print(section_change)
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    //coin_kind를 section_change2로 변환
    func add_check_change(){
        section_change = []
        if(!(coin_kind.count == 0)){
            for i in 0...coin_kind.count - 1 {
                if(!section_change.contains(coin_kind[i][1])){
                    if !(coin_kind[i][4] == "wallet"){
                        
                    }
                    section_change.append(coin_kind[i][1]);
                }
            }
            section_change2 =  [[[String]]](repeating:
                [[String]](repeating: [], count: 0), count: section_change.count)
            for ii in 0...section_change.count - 1 {
                for i in 0...coin_kind.count - 1 {
                    if(coin_kind[i][1].contains(section_change[ii])){
                        //print(coin_kind[i][4])
                        if !(coin_kind[i][4] == "wallet"){
                            section_change2[ii].append(coin_kind[i])
                        }
                    }
                }
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
       
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            //expanded
            
            var heightt = 0
            //heightt = heightt + section_change2.count * 25
            
            for i in 0...section_change2.count - 1 {
                heightt = heightt + section_change2[i].count * 55 + 0
            }
            //print(heightt)
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(heightt))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func load_arr() {
        coin_kind = []
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "arr") ?? "")
        
        if gettext == ""{
            return
        }
        
        var tmp: [String] = []
        tmp = gettext.components(separatedBy: "#")
        
        for i in 0...tmp.count - 2 {
            var tmpp_data = tmp[i].components(separatedBy: "@")
            if tmpp_data.count == 3{
                if (tmpp_data[2] == "wallet"){
                    //coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---",tmpp_data[2]])
                }else{
                    coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---","---"])
                }
            }else{
                coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---","---"])
            }
            
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
    
    
}



extension TodayViewController: UITableViewDelegate,UITableViewDataSource {
    
    //테이블 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return section_change.count
    }
    //테이블 섹션 이름
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "   " + section_change[section]
    }
    
    //클릭 시
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")//print("row: \(indexPath.row)")
        /*
        for i in 0...3{
            table_controller.send_data[i] = section_change2[indexPath.section][indexPath.row][i]
        }
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "chart") as! chart
        self.navigationController?.pushViewController(secondViewController, animated: true)*/
    }
    //섹션 별 개수 가져오기
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for i in 0...section_change2.count - 1 {
            if(section == i){
                return section_change2[i].count
            }
        }
        return 0
    }
    //section 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
     func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)!
        header.textLabel?.textColor = UIColor.gray
        //header.backgroundColor = UIColor.gray
    }
    
    //테이블 데이터 로드
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "coincell4", for: indexPath) as! coincell4
        
        //코인 이름 저장
        //cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        cell.coin_name.text = section_change2[indexPath.section][indexPath.row][0]
        
        var word = ""
        
        var pricee = section_change2[indexPath.section][indexPath.row][2]
        
        let change_name = section_change2[indexPath.section][indexPath.row][1]
        cell.change2.text = change_name
        if (change_name == "Bithumb") || (change_name == "Coinone") || (change_name == "Coinnest") || (change_name == "Bithumb") || (change_name == "Korbit") || (change_name == "Upbit"){
            word = "KRW"
        }
        else if (change_name == "Binance") || (change_name == "BitFinex") || (change_name == "BitTrex") || (change_name == "Cexio") || (change_name == "Gateio") || (change_name == "Yobit") || (change_name == "Poloniex"){
            //word_x = Double(Float(TodayViewController.usd)!)
            //print(pricee)
            //print(TodayViewController.usd)
            if (pricee != "---") && (pricee != "ip"){
                pricee = (Double(pricee)! / Double(TodayViewController.usd)!).description
            }
            
            word = "USD"
        }
        else if (change_name == "BitFlyer"){
            if (pricee != "---") && (pricee != "ip"){
                pricee = (Double(pricee)! / Double(TodayViewController.jpy)! * 100).description
            }
            //word_x = Double(Float(TodayViewController.jpy)!)
            word = "JPY"
        }
        
        //거래소 이름 저장
        cell.change.text = section_change2[indexPath.section][indexPath.row][1] + " | " + word
        
        //가격 이름 저장
        
        if !(Float(section_change2[indexPath.section][indexPath.row][2]) == nil){
            cell.price.textColor = UIColor.black

            //한화
            var price_tmp = pricee

            price_tmp = coma(str: pricee)
            if (price_tmp.contains(".0")){
                price_tmp = price_tmp.components(separatedBy: ".0")[0]
            }
            cell.price.text = price_tmp
        }else{
            cell.price.textColor = UIColor.gray
            if pricee == "---"{
                cell.price.text = "로딩중"//로딩중
            }else if pricee == "미지원"{
                cell.price.text = "미지원"
            }
            else if pricee == "ip"{
                cell.price.text = "오류"
            }else{
                cell.price.text = "오류"
            }
        }
        
        //전일대비 이름 저장
        cell.before.layer.cornerRadius = 5
        cell.before.layer.masksToBounds = true
        let before_v = section_change2[indexPath.section][indexPath.row][3]
        let tmp_before = Float(before_v)
        if tmp_before == nil{
            cell.before.textColor = UIColor.gray
            if before_v == "---"{
                cell.before.text = "로딩중"//로딩중
            }else if before_v == "미지원"{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.before.textColor = UIColor.white
                cell.before.text = "미지원"
            }else if before_v == "ip"{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.before.textColor = UIColor.white
                cell.before.text = "오류"
            }else{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.before.textColor = UIColor.white
                cell.before.text = "오류"
            }
        }else{
            cell.before.text = "" + section_change2[indexPath.section][indexPath.row ][3] + "% "
            if section_change2[indexPath.section][indexPath.row ][3] == "0"{
                //cell.before.text = "---" + ""
            }
            if tmp_before! > Float(0)   {
                cell.before.backgroundColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.6)
                cell.before.textColor = UIColor.white
            }else if  tmp_before! < Float(0) {
                cell.before.backgroundColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 0.6)
                cell.before.textColor = UIColor.white
            }else{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.before.textColor = UIColor.white
            }
        }
        
        
        //프리미엄 이름 저장
        cell.primium.layer.cornerRadius = 5
        cell.primium.layer.masksToBounds = true
        var tmp2 = Float(0.0)
        let compare = section_change2[indexPath.section][indexPath.row ][0]//오류부분
        if (primium.count > 0) && !(Float(pricee) == nil) && pricee != "---"
            && ((primium.contains {$0.contains(compare)})){
            for i in 0...primium.count - 1 {
                if  primium[i][0] == compare{
                    if (Float(pricee)! == 0) || (Float(primium[i][1])! == 0){///이것도 시발ㄹ
                        cell.primium.text = "없음"
                        cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                        cell.primium.textColor = UIColor.white
                        continue
                    }
                    let rslt  = ((Float(section_change2[indexPath.section][indexPath.row][2])! - Float(primium[i][1])!) / Float(primium[i][1])! * 100)//오류부분
                    if(rslt < -99 || rslt > 99){
                        //break
                    }
                    tmp2 = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))
                    if tmp2.description.contains("100"){
                        //break
                    }
                    var plus = ""
                    if tmp2 > Float(0)   {
                        plus = "+"
                        cell.primium.backgroundColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.6)
                        cell.primium.textColor = UIColor.white
                    }else if  tmp2 < Float(0) {
                        cell.primium.backgroundColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 0.6)
                        cell.primium.textColor = UIColor.white
                    }else{
                        cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                        cell.primium.textColor = UIColor.white
                    }
                    cell.primium.text = "" + plus + (tmp2.description) + "% "
                }
            }
        }else{
            cell.primium.textColor = UIColor.gray
            if pricee == "---"{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.primium.textColor = UIColor.white
                cell.primium.text = "로딩중"//로딩중
            }else if pricee == "미지원"{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.primium.textColor = UIColor.white
                cell.primium.text = "미지원"
            }else if pricee == "ip"{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.primium.textColor = UIColor.white
                cell.primium.text = "오류"
            }else{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.6)
                cell.primium.textColor = UIColor.white
                cell.primium.text = "없음"
            }
        }
        
        
        let tmp1_ = cell.price.text
        let tmp2_ = cell.before.text
        let tmp3_ = cell.primium.text
        
        if (tmp1_ == tmp3_ && tmp3_ == tmp2_){
            cell.price.text = ""
            cell.before.text = ""
        }
        
        return cell
    }
    
    func coma(str:String) ->String{
        var comback = ""
        var tmpp = str
        if tmpp.contains("."){
            comback = tmpp.components(separatedBy: ".")[1]
            if comback.count >= 2{
                comback = comback.substring(to: comback.index(comback.startIndex, offsetBy: 2))
            }
            tmpp = tmpp.components(separatedBy: ".")[0]
            
        }
        var price_tmp = tmpp
        var made_price = ""
        while price_tmp.count >= 3{
            let str_cnt = price_tmp.count
            let back = price_tmp.substring(from: price_tmp.index(price_tmp.endIndex, offsetBy: -3))
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
    
    func coma_order(str:String) ->String{
        var tmpp = str
        var tmpp2 = ""
        if tmpp.contains("."){
            tmpp2 = tmpp.components(separatedBy: ".")[1]
            tmpp = tmpp.components(separatedBy: ".")[0]
            tmpp2 = "." + tmpp2
        }
        var price_tmp = tmpp
        var made_price = ""
        while price_tmp.count >= 3{
            let str_cnt = price_tmp.count
            let back = price_tmp.substring(from: price_tmp.index(price_tmp.endIndex, offsetBy: -3))
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
        
        if made_price.count > 3{
            return made_price
        }else{
            return made_price + tmpp2
        }
        
        
        
        
    }
    
}
