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

class coincell4: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var before: UILabel!
    @IBOutlet weak var primium: UILabel!
}

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var enablecant = 6
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
        reload_text.setTitle(enablecant.description, for: .normal)

        if( enablecant < 0){
            enablecant = 6
            reload_text.isEnabled = true
            reload_text.setTitle("새로고침", for: .normal)
            timer.invalidate()
        }
        enablecant = enablecant - 1
    }
    
    static var cny = "0"//환율
    static var jpy = "0"//환율
    var timer3:Timer!
    var timer:Timer!
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load_arr()
        load_primium()
        load_kind()
        
        list_refresh()
        scan_all()

        if(timer3 != nil) {timer3.invalidate()}
        timer3 = Timer(timeInterval: 2.0, target: self, selector: #selector(TodayViewController.timerDidFire3), userInfo: nil, repeats: true)
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
            let url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?_callback=a&pkid=141&key=exchangeApiNationOnly&where=nexearch&q=1%EB%8B%AC%EB%9F%AC&u1=keb&u6=standardUnit&u7=0&u3=USD&u4=KRW&u5=info&u2=1")
            
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                //print(parset)
                //table_controller.usd = (parset?.components(separatedBy: "\"KRW\":")[1].components(separatedBy: "}")[0])!
                TodayViewController.usd = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
                
            }
            task.resume()
            
        
            var tmp_str = ""
            for i in 0...section_change.count - 1 {
                if(section_change[i] == "Bithumb" || primium_change == "Bithumb"){
                    tmp_str = tmp_str + "bithumb"
                }
                if(section_change[i] == "Coinone" || primium_change == "Coinone"){
                    tmp_str = tmp_str + "coinone"
                }
                if(section_change[i] == "Poloniex" || primium_change == "Poloniex"){
                    tmp_str = tmp_str + "poloniex"
                }
                if(section_change[i] == "BitTrex" || primium_change == "BitTrex"){
                    tmp_str = tmp_str + "bittrex"
                }
                if(section_change[i] == "BitFinex" || primium_change == "Bitfinex"){
                    tmp_str = tmp_str + "bitfinex"
                }
                if(section_change[i] == "Korbit" || primium_change == "Korbit"){
                    tmp_str = tmp_str + "korbit"
                }
                if(section_change[i] == "Coinnest" || primium_change == "Coinnest"){
                    tmp_str = tmp_str + "coinnest"
                }
                if(section_change[i] == "Huobi" || primium_change == "Huobi"){
                    //tmp_str = tmp_str + "poloniex"
                }
                if(section_change[i] == "Okcoin" || primium_change == "Okcoin"){
                    //ticker_okcoin()
                    
                }
                if(section_change[i] == "BitFlyer" || primium_change == "BitFlyer"){
                    tmp_str = tmp_str + "bitflyer"
                }
                
                
            }
            if(tmp_str.contains("bithumb")){ticker_bithumb()}
            if(tmp_str.contains("coinone")){ticker_coinone()}
            if(tmp_str.contains("poloniex")){ticker_poloniex()}
            if(tmp_str.contains("bittrex")){ticker_bittrex()}
            if(tmp_str.contains("bitfinex")){ticker_bitfinex()}
            if(tmp_str.contains("korbit")){ticker_korbit()}
            if(tmp_str.contains("coinnest")){ticker_coinnest()}
            if(tmp_str.contains("bitflyer")){ticker_bitflyer()}
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
        if(!(coin_kind.count == 0)){
            for i in 0...coin_kind.count - 1 {
                if(!section_change.contains(coin_kind[i][1])){
                    section_change.append(coin_kind[i][1]);
                }
            }
            section_change2 =  [[[String]]](repeating:
                [[String]](repeating: [], count: 0), count: section_change.count)
            for ii in 0...section_change.count - 1 {
                for i in 0...coin_kind.count - 1 {
                    if(coin_kind[i][1].contains(section_change[ii])){
                        section_change2[ii].append(coin_kind[i])
                    }
                }
            }
        }
    }
    
    func add_check_change2(){
        if(!(coin_kind.count == 0)){
            for i in 0...coin_kind.count - 1 {
                if(!section_change.contains(coin_kind[i][0])){
                    section_change.append(coin_kind[i][0]);
                }
            }
            section_change2 =  [[[String]]](repeating:
                [[String]](repeating: [], count: 0), count: section_change.count)
            for ii in 0...section_change.count - 1 {
                for i in 0...coin_kind.count - 1 {
                    if(coin_kind[i][0].contains(section_change[ii])){
                        section_change2[ii].append(coin_kind[i])
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
            
            var heightt = 40
            //heightt = heightt + section_change2.count * 25
            for i in 0...section_change2.count - 1 {
                heightt = heightt + section_change2[i].count * 35 + 25
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
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "arr") ?? "")
        
        coin_kind = []
        
        if gettext == "0"{
            return
        }
        
        var tmp: [String] = []
        tmp = gettext.components(separatedBy: "#")
        
        for i in 0...tmp.count - 2 {
            coin_kind.append([tmp[i].components(separatedBy: "@")[0], tmp[i].components(separatedBy: "@")[1],"---","---"])
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
        catch {}
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }
    
    func load_kind() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "kind") ?? "")
        
        do {
            kind_price=gettext
        }
        catch {}
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
        cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        cell.coin_name.text = section_change2[indexPath.section][indexPath.row][0]
        
        //거래소 이름 저장
        cell.change.text = section_change2[indexPath.section][indexPath.row][1]
        
        //가격 이름 저장
        var pricee = section_change2[indexPath.section][indexPath.row][2]
        if !(Float(section_change2[indexPath.section][indexPath.row][2]) == nil){
            cell.price.textColor = UIColor.black
            var price_tmp = ""
            //한화
            if (kind_price == "" || kind_price == "KRW"){
                if pricee.contains("."){
                    pricee = pricee.components(separatedBy: ".")[0]
                }
                price_tmp = pricee
                var made_price = ""
                while price_tmp.characters.count >= 3{
                    let str_cnt = price_tmp.characters.count
                    let back = price_tmp.substring(from: price_tmp.index(price_tmp.endIndex, offsetBy: -3))
                    price_tmp = price_tmp.substring(to: price_tmp.index(price_tmp.startIndex, offsetBy: str_cnt-3))
                    if (made_price == ""){made_price = back
                    }else{made_price = back + "," + made_price
                    }
                }
                if !(price_tmp.characters.count == 0){
                    if (made_price == ""){made_price = price_tmp
                    }else{made_price = price_tmp + "," + made_price
                    }
                }
                cell.price.text = made_price + "￦"
            }else{//달러
                price_tmp = String(Float(pricee)! / Float(TodayViewController.usd)!)
                let tmp = round(Float(price_tmp)! * pow(10.0, Float(2))) / pow(10.0, Float(2))
                cell.price.text = String(tmp) + "$"
            }
        }else{
            cell.price.textColor = UIColor.gray
            if pricee == "---"{
                cell.price.text = "로딩중"//로딩중
            }else if pricee == "미지원"{
                cell.price.text = "미지원"
            }
            else if pricee == "ip"{
                cell.price.text = "IP차단"
            }else{
                cell.price.text = "오류"
            }
        }
        
        //전일대비 이름 저장
        let before_v = section_change2[indexPath.section][indexPath.row][3]
        let tmp_before = Float(before_v)
        if tmp_before == nil{
            cell.before.textColor = UIColor.gray
            if before_v == "---"{
                cell.before.text = "로딩중"//로딩중
            }else if before_v == "미지원"{
                cell.before.text = "미지원"
            }else if before_v == "ip"{
                cell.before.text = "IP차단"
            }else{
                cell.before.text = "오류"
            }
        }else{
            cell.before.text = section_change2[indexPath.section][indexPath.row][3] + "%"
            if section_change2[indexPath.section][indexPath.row][3] == "0"{
                //cell.before.text = "---" + ""
            }
            if tmp_before! > Float(0)   {
                cell.before.textColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
            }else if  tmp_before! < Float(0) {
                cell.before.textColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
            }else{
                cell.before.textColor = UIColor.gray
            }
        }
        
        
        //프리미엄 이름 저장
        var tmp2 = Float(0.0)
        let compare = section_change2[indexPath.section][indexPath.row][0]//오류부분
        if (primium.count > 0) && !(Float(pricee) == nil) && (primium.contains {$0.contains(compare)}){
            for i in 0...primium.count - 1 {
                let compare2 = primium[i]////////////시발이거 어캐고침
                let compare3 = compare2[0]
                if  compare3 == compare{
                    if (Float(pricee)! == 0) || (Float(primium[i][1])! == 0){///이것도 시발ㄹ
                        break
                    }
                    let rslt  = ((Float(pricee)! - Float(primium[i][1])!) / Float(pricee)! * 100)//오류부분
                    if(rslt < -99 || rslt > 99){
                        break
                    }
                    tmp2 = round(rslt * pow(10.0, Float(2))) / pow(10.0, Float(2))
                    if tmp2.description.contains("100"){
                        break
                    }
                    var plus = ""
                    if tmp2 > Float(0)   {
                        plus = "+"
                        cell.primium.textColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
                    }else if  tmp2 < Float(0) {
                        cell.primium.textColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
                    }else{
                        cell.primium.textColor = UIColor.gray
                    }
                    cell.primium.text = plus + (tmp2.description) + "%"
                }
            }
        }else{
            cell.primium.textColor = UIColor.gray
            if pricee == "---"{
                cell.primium.text = "로딩중"//로딩중
            }else if pricee == "미지원"{
                cell.primium.text = "미지원"
            }else if pricee == "ip"{
                cell.primium.text = "IP차단"
            }else{
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
    
}
