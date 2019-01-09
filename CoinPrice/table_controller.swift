//
//  FirstViewController.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 10..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import Foundation
import ZAlertView
import UserNotifications


enum Example {
    case helloWorld, candleStick
}

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

class coincell2: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var before: UILabel!
    @IBOutlet weak var primium: UILabel!
    @IBOutlet var price_sub: UILabel!
    @IBOutlet var name2: UILabel!
    @IBOutlet var vol: UILabel!
}

class header: UITableViewCell {

    @IBOutlet weak var changer: UILabel!
    @IBOutlet weak var img: UIImageView!
}

class table_controller: UITableViewController  {
    //, UIViewControllerPreviewingDelegate
    static var right_now_refresh = 0
    static var usd = "0" , cny = "0" , jpy = "0"
    static var usd_r = "0" , cny_r = "0" , jpy_r = "0"
    static var usd_f = "0" , cny_f = "0" , jpy_f = "0"
    static var water = "---"//환율
    static var send_data = ["0","0","0","0","0"]//차트 컨트롤로에서 참고할 변수
    private var previewingViewController: UIViewController?
    
    var price_krw_tmp = Double(0)
    var section_cnt = 0
    var is_scroll = 0
    var timeCount:Float = 7 //5초마다 갱신
    var timer:Timer! , timer2:Timer! , timer3:Timer!
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    
    @IBOutlet weak var pri_text: UIButton!
    @IBOutlet weak var time_pro: UIProgressView!//상단 새로고침 현황
    @IBAction func primium_s(_ sender: Any) {add_pri()}
    @IBOutlet weak var tableview: UITableView!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewWillAppear(_ animated: Bool){
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        init_()
        table_controller.right_now_refresh = 1
        //UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        time_pro.transform = time_pro.transform.scaledBy(x: 1, y: 1)//프로그래스 두껍게
        ZAlertView.positiveColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
        ZAlertView.negativeColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
        
        load_arr()
        load_primium()
        load_kind()
        list_refresh()
        scan_all()
        
        timerDidFire3()
        //self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.clipsToBounds = true
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        //registerForPreviewing(with: self, sourceView: tableview)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(table_controller.add_coin(_:)))
        let rightButton = UIBarButtonItem(title: "편집", style: UIBarButtonItem.Style.plain, target: self, action: #selector(table_controller.showEditing(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 7.0, target: self, selector: #selector(table_controller.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
        if(timer2 != nil){timer2.invalidate()}
        timer2 = Timer(timeInterval: 0.05, target: self, selector: #selector(table_controller.timerDidFire2), userInfo: nil, repeats: true)
        RunLoop.current.add(timer2, forMode: RunLoop.Mode.common)
        
        if(timer3 != nil) {timer3.invalidate()}
        timer3 = Timer(timeInterval: 2.0, target: self, selector: #selector(table_controller.timerDidFire3), userInfo: nil, repeats: true)
        RunLoop.current.add(timer3, forMode: RunLoop.Mode.common)
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    //거래소 순서 변경
    @objc func change_main(_ button:UIBarButtonItem!){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "change_c") as! change_c
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    //테이플 편집 버튼
    @objc func showEditing(_ button:UIBarButtonItem!){
        if(self.tableView.isEditing == true){
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "편집"
            self.title = "코인 시세"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(table_controller.add_coin(_:)))
        }
        else{
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "저장"
            self.title = ""
            let leftButton = UIBarButtonItem(title: "거래소 순서 변경", style: UIBarButtonItem.Style.plain, target: self, action: #selector(table_controller.change_main(_:)))
            self.navigationItem.leftBarButtonItem = leftButton
        }
    }
    //가격 스캔
    func scan_all(){
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
    
    func list_refresh(){
        add_check_change()
        tableview.reloadData()
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    //저장된 코인을 거래소별로 정리
    func add_check_change(){
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
                            //print(coin_kind[i])
                            section_change2[ii].append(coin_kind[i])
                        }else{
                            //print("wallet")
                        }
                    }
                }
            }
        }
    }
    
    //10초에 한번씩 스캔
    @objc func timerDidFire(){
        scan_all()
        timeCount = 7.0
    }
    
    //실시간으로 계속 돌아감
    @objc func timerDidFire2(){
        if timeCount > 0{timeCount -= 0.05}
        time_pro.progress = Float(timeCount)/7
        if table_controller.right_now_refresh == 1{
            table_controller.right_now_refresh = 0
            scan_all()
            
            //프로그래스바 켜기 끄기
            defaults?.synchronize()
            let gettext = String(describing: defaults!.object(forKey: "progress_on") ?? "")
            if gettext == "" || gettext == "1"{
                time_pro.isHidden = true
            }else{
                time_pro.isHidden = true
            }
            //환율 계산 변경
            let gettext2 = String(describing: defaults!.object(forKey: "money_v") ?? "")
            if gettext2 == "" || gettext2 == "0"{
                table_controller.usd = table_controller.usd_r
                table_controller.jpy = table_controller.jpy_r
                table_controller.cny = table_controller.cny_r
            }else{
                table_controller.usd = table_controller.usd_f
                table_controller.jpy = table_controller.jpy_f
                table_controller.cny = table_controller.cny_f
            }
            list_refresh()
        }
    }
    
    //프리미엄 스캔
    @objc func timerDidFire3(){
        if is_scroll == 0 && self.tableView.isEditing == false{
            list_refresh()
            if !(primium_change == primium_change_tmp){
                primium_change_tmp = primium_change
                if primium_change == "Bitfinex"{self.pri_text.setTitle("Bitfinex", for: UIControl.State.normal)}
                if primium_change == "BitTrex"{self.pri_text.setTitle("Bittrex", for: UIControl.State.normal)}
                if primium_change == "Poloniex"{self.pri_text.setTitle("Poloniex", for: UIControl.State.normal)}
                if primium_change == "Bithumb"{self.pri_text.setTitle("Bithumb", for: UIControl.State.normal)}
                if primium_change == "Coinone"{self.pri_text.setTitle("Coinone", for: UIControl.State.normal)}
                if primium_change == "Upbit"{self.pri_text.setTitle("Upbit", for: UIControl.State.normal)}
                if primium_change == "Yobit"{self.pri_text.setTitle("Yobit", for: UIControl.State.normal)}
                if primium_change == "Binance"{self.pri_text.setTitle("Binance", for: UIControl.State.normal)}
                if primium_change == "Gateio"{self.pri_text.setTitle("Gateio", for: UIControl.State.normal)}
                if primium_change == "Cexio"{self.pri_text.setTitle("Cexio", for: UIControl.State.normal)}
                
                self.save_primium()
                self.save_kind()
                primium = []
                self.scan_all()
                self.list_refresh()
            }
        }
    }
    //--------------------------------------------------------------
    //테이블 높이
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 55
    }
    //테이블 섹션 개수
    override func numberOfSections(in tableView: UITableView) -> Int {
        return section_change.count
    }
    //테이블 섹션 이름
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section_change[section]
    }
    //제거 가능 설정
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (self.tableView.isEditing == false){
            return false
        }else{
            return true
        }
    }
    
    //제거 눌렀을때
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let dialog = ZAlertView(title: "제거", message: "이 항목을 정말 제거 하시겠습니까?", closeButtonText: "확인", closeButtonHandler: {
                alertView in
                for i in 0...coin_kind.count - 1 {
                    if(section_change2[indexPath.section][indexPath.row][0].contains(coin_kind[i][0]) && section_change2[indexPath.section][indexPath.row][1].contains(coin_kind[i][1])){
                        if coin_kind[i].count == 5{
                            if !(coin_kind[i][4] == "wallet"){
                                coin_kind.remove(at: i)
                                break
                            }
                        }else{
                            coin_kind.remove(at: i)
                            break
                        }
                    }
                }
                self.save_arr()
                section_change = []
                self.list_refresh()
                alertView.dismissAlertView()
            })
            dialog.show()
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .none
    }*/
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
    }
    
    //테이블 이동
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if (sourceIndexPath.section == destinationIndexPath.section){
            
            var start = 0
            var end = 0
            for i in 0...coin_kind.count - 1 {
                if(section_change2[sourceIndexPath.section][sourceIndexPath.row][0].contains(coin_kind[i][0]) && section_change2[sourceIndexPath.section][sourceIndexPath.row][1].contains(coin_kind[i][1])){
                    start = i
                    break
                }
            }
            for i in 0...coin_kind.count - 1 {
                if(section_change2[destinationIndexPath.section][destinationIndexPath.row][0].contains(coin_kind[i][0]) && section_change2[destinationIndexPath.section][destinationIndexPath.row][1].contains(coin_kind[i][1])){
                    end = i
                    break
                }
            }
            
            let movedObject = coin_kind[start]
            //print(movedObject)
            coin_kind.remove(at: start)
            coin_kind.insert(movedObject, at: end)
            
            save_arr()
            //self.list_refresh()
            
        }else{
            self.list_refresh()
        }
    }
    //클릭 시
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialog = ZAlertView(title: "거래소 차트 선택", message: nil, alertType: ZAlertView.AlertType.multipleChoice)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "candle") as! candle
        
        //print("section: \(indexPath.section)")//print("row: \(indexPath.row)")
        for i in 0...3{
            table_controller.send_data[i] = section_change2[indexPath.section][indexPath.row][i]
        }
        //print(table_controller.send_data)
        
        if bithumb_ex.contains(">" + table_controller.send_data[0] + "/"){
            dialog.addButton("BITHUMB", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = "Bithumb"
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        if bitfinex_ex.contains(">" + table_controller.send_data[0] + "/"){
            dialog.addButton("BITFINEX", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = "BitFinex"
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        if binance_ex.contains(">" + table_controller.send_data[0] + "/"){
            dialog.addButton("BINANCE", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = "Binance"
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        dialog.show()
        if bittrex_ex.contains(">" + table_controller.send_data[0] + "/"){
            dialog.addButton("BITTREX", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = "BitTrex"
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        if poloniex_ex.contains(">" + table_controller.send_data[0] + "/"){
            dialog.addButton("POLONIEX", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = "Poloniex"
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        if korbit_ex.contains(">" + table_controller.send_data[0] + "/"){
            dialog.addButton("KORBIT", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = "Korbit"
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        
        //self.navigationController?.pushViewController(secondViewController, animated: true)
        /*let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "chart") as! chart
         self.navigationController?.pushViewController(secondViewController, animated: true)*/
    }
    //header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 37
            //return CGFloat.leastNormalMagnitude
        }
        return 37
        //return tableView.sectionHeaderHeight
    }
    //custom sction header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {

        //headerCell.backgroundColor = UIColor.cyanColor()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "header") as! header
        headerCell.changer.text = section_change[section]
        //let image: UIImage = UIImage(named: "bitfiniex")!
        headerCell.img.image = UIImage(named: section_change[section].lowercased())
        return headerCell
    }
    //섹션 별 개수 가져오기
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for i in 0...section_change2.count - 1 {
            if(section == i){
                return section_change2[i].count
            }
        }
        return 0
    }
    //section 높이
    /*
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)!
        header.textLabel?.textColor = UIColor.gray
        //header.backgroundColor = UIColor.gray
    }*/
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "coincell2", for: indexPath) as! coincell2
        //단위
        cell.name2.text = section_change2[indexPath.section][indexPath.row][5]
        
        var tmpp2 = section_change2[indexPath.section][indexPath.row][6]
        if !(tmpp2 == "---" || tmpp2 == ""){
            if tmpp2.contains("."){
                tmpp2 = tmpp2.components(separatedBy: ".")[0]
            }
            cell.vol.text = "24 vol: " + coma(str:tmpp2)
        }else{
            cell.vol.text = ""
        }
        
        //코인 이름 저장
        //cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        cell.coin_name.text = section_change2[indexPath.section][indexPath.row][0]
        
        //거래소 이름 저장
        cell.change.text = section_change2[indexPath.section][indexPath.row ][1]
        
        //가격 이름 저장
        let pricee = section_change2[indexPath.section][indexPath.row ][2]
        if !(Float(pricee) == nil){
            cell.price.textColor = UIColor.black
            //한화
            var tmpp = pricee
            if tmpp.contains("."){
               tmpp = tmpp.components(separatedBy: ".")[0]
            }
            var price_krw = coma(str: tmpp)
            if (tmpp.count < 3){
                price_krw = pricee
            }
            var b_price = ""
            b_price = cell.price.text!
            //print(b_price)
            if b_price != ""{
                if b_price.contains("원"){
                    b_price = b_price.components(separatedBy: "원")[0]
                }
                if b_price.contains(","){
                    b_price = b_price.replacingOccurrences(of: ",", with: "")
                }
                /*
                if Double(b_price)! < Double(tmpp)! {
                    cell.animationType = .background
                    cell.animationDuration = 0.5
                    cell.animationTimingAdapter = 3
                    cell.animationBackgroundColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.15)
                    cell.startAnimating()
                }else if Double(b_price)! > Double(tmpp)! {
                    cell.animationType = .background
                    cell.animationDuration = 0.5
                    cell.animationTimingAdapter = 3
                    cell.animationBackgroundColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 0.15)
                    cell.startAnimating()
                }*/
                //cell.price.blink()
            }
            
            cell.price.text = price_krw + "원"
            //price_krw_tmp = Double(price_krw)!
            //달러
            var price_tmp = String(Float(pricee)! / Float(table_controller.usd)!)
            let tmp_usd = round(Float(price_tmp)! * pow(10.0, Float(3))) / pow(10.0, Float(3))
            var price_usd = coma(str: String(tmp_usd))
            if (Float(price_usd) == 0){
                price_usd = price_tmp
            }
            //엔화
            price_tmp = String(Double(pricee)! / Double(table_controller.jpy)! * 100).description
            let tmp_cny = round(Double(price_tmp)! * pow(10.0, Double(2))) / pow(10.0, Double(2))
            var price_cny = coma(str:tmp_cny.description)
            if (Float(price_cny) == 0){
                price_cny = price_tmp
            }
            
            if (kind_price == "KRW"){
                cell.price_sub.text = price_tmp + "원"
            }else if(kind_price == "ALL"){
                cell.price_sub.text = price_usd + "달러"
            }else if(kind_price == "WHAT"){
                let change_name = cell.change.text
                if change_name == "Bithumb" || change_name == "Coinone" || change_name == "Korbit" || change_name == "Coinnest" || change_name == "Upbit"{
                    cell.price_sub.text = price_krw + "원"
                }else if change_name == "Poloniex" || change_name == "BitFinex" || change_name == "BitTrex" || change_name == "Yobit"{
                    cell.price_sub.text = price_usd + "달러"
                }else if change_name == "BitFlyer"{
                    cell.price_sub.text = price_cny + "엔"
                }else{
                    cell.price_sub.text = price_krw + "원"
                }
            }else if(kind_price == "USD"){
                cell.price_sub.text = price_usd + "달러"
            }else if(kind_price == "JPY"){
                cell.price_sub.text = price_cny + "엔"
            }else{
                cell.price_sub.text = price_usd + "달러"
            }
        }else{
            cell.price_sub.text = ""
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
        
        if (cell.name2.text == "KRW"){
            cell.price_sub.text = "" + cell.price_sub.text!
        }
        if (cell.name2.text == "USD"){
            cell.price.text = "" + cell.price.text!
        }
        if (cell.name2.text == "BTC"){
            cell.price_sub.text = "" + cell.price_sub.text!
            cell.price.text = "" + cell.price.text!
        }
        
        //전일대비 이름 저장
        cell.before.layer.cornerRadius = 2
        cell.before.layer.masksToBounds = true
        let before_v = section_change2[indexPath.section][indexPath.row ][3]
        let tmp_before = Float(before_v)
        if tmp_before == nil{
            cell.before.textColor = UIColor.gray
            if before_v == "---"{
                cell.before.text = "로딩중"//로딩중
            }else if before_v == "미지원"{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.before.textColor = UIColor.gray
                cell.before.text = "미지원"
            }else if before_v == "ip"{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.before.textColor = UIColor.gray
                cell.before.text = "오류"
            }else{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.before.textColor = UIColor.gray
                cell.before.text = "오류"
            }
        }else{
            cell.before.text = "" + section_change2[indexPath.section][indexPath.row ][3] + "% "
            if section_change2[indexPath.section][indexPath.row ][3] == "0"{
                //cell.before.text = "---" + ""
            }
            if tmp_before! > Float(0)   {
                cell.before.backgroundColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.1)
                cell.before.textColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
            }else if  tmp_before! < Float(0) {
                cell.before.backgroundColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 0.1)
                cell.before.textColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
            }else{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.before.textColor = UIColor.gray
            }
        }
        
        //프리미엄 이름 저장
        cell.primium.layer.cornerRadius = 2
        cell.primium.layer.masksToBounds = true
        var tmp2 = Float(0.0)
        let compare = section_change2[indexPath.section][indexPath.row ][0]//오류부분
        if (primium.count > 0) && !(Float(pricee) == nil) && pricee != "---"
            && ((primium.contains {$0.contains(compare)})){
            for i in 0...primium.count - 1 {
                if  primium[i][0] == compare{
                    if (Float(pricee)! == 0) || (Float(primium[i][1])! == 0){///이것도 시발ㄹ
                        cell.primium.text = "없음"
                        cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                        cell.primium.textColor = UIColor.gray
                        continue
                    }
                    let rslt  = ((Float(pricee)! - Float(primium[i][1])!) / Float(primium[i][1])! * 100)//오류부분
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
                        cell.primium.backgroundColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.1)
                        cell.primium.textColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
                    }else if  tmp2 < Float(0) {
                        cell.primium.backgroundColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 0.1)
                        cell.primium.textColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
                    }else{
                        cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                        cell.primium.textColor = UIColor.gray
                    }
                    cell.primium.text = "" + plus + (tmp2.description) + "% "
                }
            }
        }else{
            cell.primium.textColor = UIColor.gray
            if pricee == "---"{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.primium.textColor = UIColor.gray
                cell.primium.text = "로딩중"//로딩중
            }else if pricee == "미지원"{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.primium.textColor = UIColor.gray
                cell.primium.text = "미지원"
            }else if pricee == "ip"{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.primium.textColor = UIColor.gray
                cell.primium.text = "오류"
            }else{
                cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
                cell.primium.textColor = UIColor.gray
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
    /*
     //테이들 포스터치
     func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
     if tableView.isEditing == false {
     
     guard let indexPath = tableView.indexPathForRow(at: location) else {
     print("Nil Cell Found: \(location)")
     return nil }
     guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "candle") else { return nil }
     //print(indexPath)
     for i in 0...3{
     table_controller.send_data[i] = section_change2[indexPath[0]][indexPath[1]][i]
     }
     previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
     
     //print(location)
     /*
     guard let indexPath = tableView.indexPathForRow(at: location) else {
     print("Nil Cell Found: \(location)")
     return nil }
     guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "chart") else { return nil }
     //print(indexPath)
     for i in 0...3{
     table_controller.send_data[i] = section_change2[indexPath[0]][indexPath[1]][i]
     }
     previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
     */
     return detailVC
     } else {
     return nil
     }
     }
     //테이블 포스터치 클릭 시
     func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
     let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "candle") as! candle
     self.navigationController?.pushViewController(secondViewController, animated: true)
     
     }*/
    //------------------------------------------------------------
    
    //프리미엄 선택 팝업
    func add_pri(){
        var dialog = SelectionDialog(title: "프리미엄 거래소 선택", closeButtonTitle: "닫기")
        func add_w_item(str:String){
            dialog.addItem(item: str, didTapHandler: { () in
                primium_change = str
                dialog.close()
            })
        }
        add_w_item(str: "Binance")
        add_w_item(str: "Bitfinex")
        add_w_item(str: "Bithumb")
        add_w_item(str: "BitTrex")
        add_w_item(str: "Coinone")
        add_w_item(str: "Poloniex")
        add_w_item(str: "Upbit")
        dialog.show()
    }
    
    //코인추가 팝업
    @objc func add_coin(_ button:UIBarButtonItem!){
        var dialog = SelectionDialog(title: "코인 추가", closeButtonTitle: "닫기")
        func add_w_item(str:String){
            dialog.addItem(item: str, didTapHandler: { () in
                dialog.close()
                self.choose_coin(kind: str)
            })
        }
        add_w_item(str: "Binance")
        add_w_item(str: "BitFinex")
        add_w_item(str: "BitFlyer")
        add_w_item(str: "Bithumb")
        add_w_item(str: "BitTrex")
        add_w_item(str: "Coinnest")
        add_w_item(str: "Coinone")
        add_w_item(str: "Korbit")
        add_w_item(str: "Poloniex")
        add_w_item(str: "Upbit")
        dialog.show()
    }
    
    //추가하려는 코인 배열에 입력
    func choose_coin(kind: String){
        let dialog2 = ZAlertView(title: kind, message: "코인 종류를 입력해주세요.", isOkButtonLeft: false, okButtonText: "추가", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
            let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("coin_choose")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
            if !get_tmp.contains("@") && !get_tmp.contains("#") && !get_tmp.contains(" ") && !(get_tmp == "") && get_tmp.isAlphanumeric2{
                coin_kind.append([get_tmp.uppercased(), kind,"---","---","---","---","---"])
                self.save_arr()
                self.list_refresh()
                self.scan_all()
                
            }else{
                let dialog = ZAlertView(title: "오류",message: "입력 값에 오류가 있습니다.",closeButtonText: "확인",closeButtonHandler: { alertView in alertView.dismissAlertView()})
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
        },cancelButtonHandler: { alertView in alertView.dismissAlertView()})
        dialog2.addTextField("coin_choose", placeHolder: "ex)BTC,BCH,ETH,ETC...")
        dialog2.show()
    }
    
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
    
    func save_arr() {
        var text = ""
        if !(coin_kind.count == 0){
            for i in 0...coin_kind.count - 1 {
                if coin_kind[i].count == 7{
                    if (coin_kind[i][4] == "wallet"){
                        //text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + coin_kind[i][4] + "#")
                    }else{
                        text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                    }
                }else{
                    text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                }
                
            }
        }
        //print(text)
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(text), forKey: "arr")
        defaults?.synchronize()
    }
    
    func load_primium() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "primium") ?? "")
        do {
            primium_change=gettext
            if primium_change == "Binance"{self.pri_text.setTitle("Binance", for: UIControl.State.normal)}
            if primium_change == "Bitfinex"{self.pri_text.setTitle("Bitfinex", for: UIControl.State.normal)}
            if primium_change == "BitTrex"{self.pri_text.setTitle("Bittrex", for: UIControl.State.normal)}
            if primium_change == "Cexio"{self.pri_text.setTitle("Cexio", for: UIControl.State.normal)}
            if primium_change == "Poloniex"{self.pri_text.setTitle("Poloniex", for: UIControl.State.normal)}
            if primium_change == "Bithumb"{self.pri_text.setTitle("Bithumb", for: UIControl.State.normal)}
            if primium_change == "Coinone"{self.pri_text.setTitle("Coinone", for: UIControl.State.normal)}
            if primium_change == "Gateio"{self.pri_text.setTitle("Gateio", for: UIControl.State.normal)}
            if primium_change == "Upbit"{self.pri_text.setTitle("Upbit", for: UIControl.State.normal)}
        }
    }
    
    func save_primium() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(primium_change), forKey: "primium")
        defaults?.synchronize()
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
    
    func save_kind() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(kind_price), forKey: "kind")
        defaults?.synchronize()
    }
    
    @IBAction func select_kind_price(_ sender: Any) {
        let dialog = ZAlertView(title: "표시 단위 : " + kind_price, message: nil, alertType: ZAlertView.AlertType.multipleChoice)
        dialog.addButton("거래소별 단위", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "WHAT"
            self.save_kind()
            self.list_refresh()
        })
        dialog.addButton("달러(USD)", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "USD"
            self.save_kind()
            self.list_refresh()
        })
        dialog.addButton("엔(JPY)", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "JPY"
            self.save_kind()
            self.list_refresh()
        })
        dialog.show()
    }
    /*
     override var shouldAutorotate: Bool {
     return true
     }
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
     return .portrait
     }
     override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
     return .portrait
     }*/
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        is_scroll = 1
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        is_scroll = 0
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
                let symbol = self.split2(str: cnt![i],w1: "\"symbol\": \"", w2: "\"")
                let vol = self.split2(str: cnt![i],w1: "\"24h_volume_usd\": \"", w2: "\"")
                let price = self.split2(str: cnt![i],w1: "\"price_usd\": \"", w2: "\"")
                let change = self.split2(str: cnt![i],w1: "\"percent_change_24h\": \"", w2: "\"")
                
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


extension String {
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
    var isAlphanumeric2: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
extension UILabel {
    func blink() {
        self.layer.borderWidth = 0.8
        self.layer.borderColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0).cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.layer.borderColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 0.0).cgColor
        }
    }
}
