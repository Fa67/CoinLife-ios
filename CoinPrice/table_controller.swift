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


var coin_kind: [[String]] = []//여기에 걍 막 저장
var coin_kind_wallet : [[String]] = []
var section_change: [String] = []//거래소 리스트
var section_change2 : [[[String]]] = []//거래소 별로 저장
var primium: [[String]] = [] //프리미엄 싹다 저장

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
}

class table_controller: UITableViewController , UIViewControllerPreviewingDelegate {
    static var right_now_scan = 0
    static var right_now_refresh = 0
    
    var section_cnt = 0
    private var previewingViewController: UIViewController?
    @IBOutlet weak var pri_text: UIButton!
    var is_scroll = 0
    static var usd = "0"//환율
    static var cny = "0"//환율
    static var jpy = "0"//환율
    static var eur = "0"//환율
    
    static var usd_r = "0"//환율
    static var cny_r = "0"//환율
    static var jpy_r = "0"//환율
    static var eur_r = "0"//환율
    
    static var usd_f = "0"//환율
    static var cny_f = "0"//환율
    static var jpy_f = "0"//환율
    static var eur_f = "0"//환율
    
    static var water = "---"//환율
    var timeCount:Float = 10 //5초마다 갱신
    var timer:Timer! , timer2:Timer! , timer3:Timer!
    @IBOutlet weak var time_pro: UIProgressView!//상단 새로고침 현황
    static var send_data = ["0","0","0","0","0"]//차트 컨트롤로에서 참고할 변수
    
    @IBAction func primium_s(_ sender: Any) {add_pri()}
    @IBOutlet weak var tableview: UITableView!
    
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //timer?.invalidate()//timer = nil
    }
    
    override func viewWillAppear(_ animated: Bool){
        //print("appear")
    }
    
    func split(str:String,w1:String,w2:String) -> String{
        return str.components(separatedBy: w1)[1].components(separatedBy: w2)[0]
    }

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        time_pro.transform = time_pro.transform.scaledBy(x: 1, y: 1)//프로그래스 두껍게
        ZAlertView.positiveColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
        ZAlertView.negativeColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
        
        get_money_value()
        
        load_arr()
        load_primium()
        load_kind()
        
        list_refresh()
        scan_all()
        
        timerDidFire3()
        //self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.clipsToBounds = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        registerForPreviewing(with: self, sourceView: tableview)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(table_controller.add_coin(_:)))
        let rightButton = UIBarButtonItem(title: "편집", style: UIBarButtonItemStyle.plain, target: self, action: #selector(table_controller.showEditing(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 10.0, target: self, selector: #selector(table_controller.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        
        if(timer2 != nil){timer2.invalidate()}
        timer2 = Timer(timeInterval: 0.05, target: self, selector: #selector(table_controller.timerDidFire2), userInfo: nil, repeats: true)
        RunLoop.current.add(timer2, forMode: RunLoopMode.commonModes)
        
        if(timer3 != nil) {timer3.invalidate()}
        timer3 = Timer(timeInterval: 2.0, target: self, selector: #selector(table_controller.timerDidFire3), userInfo: nil, repeats: true)
        RunLoop.current.add(timer3, forMode: RunLoopMode.commonModes)
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    
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
            let leftButton = UIBarButtonItem(title: "거래소 순서 변경", style: UIBarButtonItemStyle.plain, target: self, action: #selector(table_controller.change_main(_:)))
            self.navigationItem.leftBarButtonItem = leftButton
        }
    }
    
    func scan_all(){
        if !(section_change.count == 0){
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
    
    
    func list_refresh(){
        add_check_change()
        tableview.reloadData()
    }
    
    //coin_kind를 section_change2로 변환
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
                            section_change2[ii].append(coin_kind[i])
                        }
                    }
                }
            }
        }
    }
    
    @objc func timerDidFire(){
        scan_all()
        timeCount = 10.0
    }
    
    @objc func timerDidFire2(){
        if timeCount > 0{timeCount -= 0.05}
        time_pro.progress = Float(timeCount)/10
        if table_controller.right_now_refresh == 1{
            table_controller.right_now_refresh = 0
            list_refresh()
        }
    }
    
    @objc func timerDidFire3(){
        
        
        if table_controller.right_now_scan == 1{
            table_controller.right_now_scan = 0
            scan_all()
        }
        
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "progress_on") ?? "")
        if gettext == "" || gettext == "1"{
            time_pro.isHidden = false
        }else{
            time_pro.isHidden = true
        }
        
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
        
        if is_scroll == 0 && self.tableView.isEditing == false{
            list_refresh()
            if !(primium_change == primium_change_tmp){
                primium_change_tmp = primium_change
                if primium_change == "Bitfinex"{self.pri_text.setTitle("Bitfinex", for: .normal)}
                if primium_change == "BitTrex"{self.pri_text.setTitle("Bittrex", for: .normal)}
                if primium_change == "Poloniex"{self.pri_text.setTitle("Poloniex", for: .normal)}
                if primium_change == "Bithumb"{self.pri_text.setTitle("Bithumb", for: .normal)}
                if primium_change == "Coinone"{self.pri_text.setTitle("Coinone", for: .normal)}
                
                self.save_primium()
                self.save_kind()
                primium = []
                self.scan_all()
                self.list_refresh()
            }
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if kind_price == "ALL"{
            return 55
        }else{
            return 55
        }
        //return 100.0;//Choose your custom row height
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
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
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }*/
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
            print(movedObject)
            coin_kind.remove(at: start)
            coin_kind.insert(movedObject, at: end)
            
            save_arr()
            self.list_refresh()
        }else{
            self.list_refresh()
        }
    }
    //클릭 시
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")//print("row: \(indexPath.row)")
        for i in 0...3{
            table_controller.send_data[i] = section_change2[indexPath.section][indexPath.row][i]
        }
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "chart") as! chart
        self.navigationController?.pushViewController(secondViewController, animated: true)
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
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)!
        header.textLabel?.textColor = UIColor.gray
        //header.backgroundColor = UIColor.gray
    }
   
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "coincell2", for: indexPath) as! coincell2
        
        //코인 이름 저장
        cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        cell.coin_name.text = section_change2[indexPath.section][indexPath.row][0]
        
        //거래소 이름 저장
        cell.change.text = section_change2[indexPath.section][indexPath.row ][1]
        let change_name = cell.change.text
        if change_name == "Bithumb" || change_name == "Coinone" || change_name == "Korbit" || change_name == "Coinnest"{
            cell.name2.text = "KRW"
        }else if change_name == "Poloniex" || change_name == "BitFinex" || change_name == "BitTrex"{
            cell.name2.text = "USD"
        }else if change_name == "BitFlyer"{
            cell.name2.text = "JPY"
        }
        
        //가격 이름 저장
        let pricee = section_change2[indexPath.section][indexPath.row ][2]
        if !(Float(section_change2[indexPath.section][indexPath.row ][2]) == nil){
            cell.price.textColor = UIColor.black
            //한화
            var tmpp = pricee
            if tmpp.contains("."){
                tmpp = tmpp.components(separatedBy: ".")[0]
            }
            let price_krw = coma(str: tmpp)
            cell.price.text = price_krw + "￦"
            //달러
            var price_tmp = String(Float(pricee)! / Float(table_controller.usd)!)
            let tmp_usd = round(Float(price_tmp)! * pow(10.0, Float(2))) / pow(10.0, Float(2))
            let price_usd = coma(str: String(tmp_usd))
            //엔화
            price_tmp = String(Double(pricee)! / Double(table_controller.jpy)! * 100).description
            let tmp_cny = round(Double(price_tmp)! * pow(10.0, Double(2))) / pow(10.0, Double(2))
            let price_cny = coma(str:tmp_cny.description)
            
            if (kind_price == "" || kind_price == "KRW"){
                cell.price_sub.text = price_tmp + "￦"
            }else if(kind_price == "ALL"){
                cell.price_sub.text = price_usd + "$"
            }else if(kind_price == "WHAT"){
                if change_name == "Bithumb" || change_name == "Coinone" || change_name == "Korbit" || change_name == "Coinnest"{
                    cell.price_sub.text = price_krw + "￦"
                }else if change_name == "Poloniex" || change_name == "BitFinex" || change_name == "BitTrex"{
                    cell.price_sub.text = price_usd + "$"
                }else if change_name == "BitFlyer"{
                    cell.price_sub.text = price_cny + "￥"
                }else{
                    cell.price_sub.text = price_krw + "￦"
                }
            }else if(kind_price == "USD"){
                cell.price_sub.text = price_usd + "$"
            }else if(kind_price == "JPY"){
                cell.price_sub.text = price_cny + "￥"
            }else{
                cell.price_sub.text = price_usd + "$"
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
        let before_v = section_change2[indexPath.section][indexPath.row ][3]
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
            cell.before.text = section_change2[indexPath.section][indexPath.row ][3] + "%"
            if section_change2[indexPath.section][indexPath.row ][3] == "0"{
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
        let compare = section_change2[indexPath.section][indexPath.row ][0]//오류부분
        if (primium.count > 0) && !(Float(pricee) == nil)
            && ((primium.contains {$0.contains(compare)}) ||
                (primium.contains {$0.contains("DASH")}) ||
                (primium.contains {$0.contains("DSH")})  ||
                (primium.contains {$0.contains("QTM")}) ||
                (primium.contains {$0.contains("QTUM")}) ||
                (primium.contains {$0.contains("BCC")}) ||
                (primium.contains {$0.contains("BCH")})){
            for i in 0...primium.count - 1 {
                //let compare2 = primium[i]////////////시발이거 어캐고침
                //let compare3 = compare2[0]
                if  primium[i][0] == compare || (primium[i][0] == "DASH" && compare == "DSH") || (primium[i][0] == "DSH" && compare == "DSH") || (primium[i][0] == "QTM" && compare == "QTUM") || (primium[i][0] == "QTUM" && compare == "QTM") || (primium[i][0] == "BCC" && compare == "BCH") || (primium[i][0] == "BCH" && compare == "BCC"){
                    if (Float(pricee)! == 0) || (Float(primium[i][1])! == 0){///이것도 시발ㄹ
                        break
                    }
                    let rslt  = ((Float(pricee)! - Float(primium[i][1])!) / Float(pricee)! * 100)//오류부분
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
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if tableView.isEditing == false {
            
            //print(location)
            guard let indexPath = tableView.indexPathForRow(at: location) else {
                print("Nil Cell Found: \(location)")
                return nil }
            guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "chart") else { return nil }
            //print(indexPath)
            for i in 0...3{
                table_controller.send_data[i] = section_change2[indexPath[0]][indexPath[1]][i]
            }
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            
            return detailVC
            
        } else {
            return nil
            
        }
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "chart") as! chart
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    //프리미엄 선택 팝업
    func add_pri(){
        let dialog = SelectionDialog(title: "프리미엄 거래소 선택", closeButtonTitle: "닫기")
        dialog.addItem(item: "Poloniex", didTapHandler: { () in
            dialog.close()
            primium_change = "Poloniex"
        })
        dialog.addItem(item: "BitTrex", didTapHandler: { () in
            dialog.close()
            primium_change = "BitTrex"
        })
        dialog.addItem(item: "Bitfinex", didTapHandler: { () in
            dialog.close()
            primium_change = "Bitfinex"
        })
        dialog.addItem(item: "Coinone", didTapHandler: { () in
            dialog.close()
            primium_change = "Coinone"
        })
        dialog.addItem(item: "Bithumb", didTapHandler: { () in
            dialog.close()
            primium_change = "Bithumb"
        })
        dialog.show()
        
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
        while price_tmp.characters.count >= 3{
            let str_cnt = price_tmp.characters.count
            let back = price_tmp.substring(from: price_tmp.index(price_tmp.endIndex, offsetBy: -3))
            price_tmp = price_tmp.substring(to: price_tmp.index(price_tmp.startIndex, offsetBy: str_cnt-3))
            if (made_price == ""){
                made_price = back
            }else{
                made_price = back + "," + made_price
            }
        }
        if !(price_tmp.characters.count == 0){
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
    
    @objc func change_main(_ button:UIBarButtonItem!){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "change_c") as! change_c
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    //코인추가 팝업
    @objc func add_coin(_ button:UIBarButtonItem!){
        let dialog = SelectionDialog(title: "코인 추가", closeButtonTitle: "닫기")
        dialog.addItem(item: " Bithumb", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Bithumb")
        })
        dialog.addItem(item: " Coinone", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Coinone")
        })
        dialog.addItem(item: "Korbit", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Korbit")
        })
        dialog.addItem(item: "Coinnest", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Coinnest")
        })
        dialog.addItem(item: " BitTrex", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "BitTrex")
        })
        dialog.addItem(item: " Poloniex", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Poloniex")
        })
        dialog.addItem(item: " BitFinex", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "BitFinex")
        })
        dialog.addItem(item: "BitFlyer", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "BitFlyer")
        })
        dialog.show()
        dialog.addItem(item: "Huobi", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Huobi")
        })
        dialog.addItem(item: "Okcoin", didTapHandler: { () in
            dialog.close()
            self.choose_coin(kind: "Okcoin")
        })
    }
    
    //추가하려는 코인 배열에 입력
    func choose_coin(kind: String){
        let dialog2 = ZAlertView(title: kind, message: "코인 종류를 입력해주세요.", isOkButtonLeft: false, okButtonText: "추가", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
            let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("coin_choose")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
            if !get_tmp.contains("@") && !get_tmp.contains("#") && !get_tmp.contains(" ") && !(get_tmp == ""){
                coin_kind.append([get_tmp.uppercased(), kind,"---","---","---"])
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
                    coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---",tmpp_data[2]])
                }else{
                    coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---","---"])
                }
                
            }else{
                coin_kind.append([tmpp_data[0], tmpp_data[1],"---","---","---"])
            }
            
        }
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }

    func save_arr() {
        var text = ""
        if !(coin_kind.count == 0){
            for i in 0...coin_kind.count - 1 {
                if coin_kind[i].count == 5{
                    if (coin_kind[i][4] == "wallet"){
                        text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + coin_kind[i][4] + "#")
                    }else{
                        text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                    }
                }else{
                    text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "@" + "---" + "#")
                }
                
            }
        }
        
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
            if primium_change == "Bitfinex"{
                self.pri_text.setTitle("Bitfinex", for: .normal)
            }
            if primium_change == "BitTrex"{
                self.pri_text.setTitle("Bittrex", for: .normal)
            }
            if primium_change == "Poloniex"{
                self.pri_text.setTitle("Poloniex", for: .normal)
            }
            if primium_change == "Bithumb"{
                self.pri_text.setTitle("Bithumb", for: .normal)
            }
            if primium_change == "Coinone"{
                self.pri_text.setTitle("Coinone", for: .normal)
            }
        }
        catch {}
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
        catch {}
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
    
    func get_money_value(){
        var url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?_callback=a&pkid=141&key=exchangeApiNationOnly&where=nexearch&q=1%EB%8B%AC%EB%9F%AC&u1=keb&u6=standardUnit&u7=0&u3=USD&u4=KRW&u5=info&u2=1")
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
        
        url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?_callback=a&pkid=141&key=exchangeApiNationOnly&where=nexearch&q=100%EC%97%94&u1=keb&u6=standardUnit&u7=0&u3=JPY&u4=KRW&u5=info&u2=100")
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
        
        url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?_callback=a&pkid=141&key=exchangeApiNationOnly&where=nexearch&q=100%EC%97%94&u1=keb&u6=standardUnit&u7=0&u3=CNY&u4=KRW&u5=info&u2=1")
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
        
        url = URL(string: "http://hangang.dkserver.wo.tc")
        task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if (parset?.contains("\"temp\":\""))!{
                table_controller.water = (parset?.components(separatedBy: "\"temp\":\"")[1].components(separatedBy: "\",")[0])!
            }
        }
        task.resume()
    }
    
}






