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

class table_controller: UITableViewController  {

    static var right_now_refresh = 0
    static var usd = "0" , cny = "0" , jpy = "0"
    static var usd_r = "0" , cny_r = "0" , jpy_r = "0" , usd_f = "0" , cny_f = "0" , jpy_f = "0"
    static var water = "---"//환율
    static var send_data = ["0","0","0","0","0"]//차트 컨트롤로에서 참고할 변수

    var is_scroll = 0
    var timeCount:Float = 7 //5초마다 갱신
    var timer2:Timer! , timer3:Timer!
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")
    
    @IBOutlet weak var pri_text: UIButton!
    @IBOutlet weak var time_pro: UIProgressView!//상단 새로고침 현황
    @IBAction func primium_s(_ sender: Any) {add_pri()}
    @IBOutlet weak var tableview: UITableView!
    
    //private var previewingViewController: UIViewController?
    //var price_krw_tmp = Double(0)
    //var section_cnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(table_controller.add_coin(_:)))
        let rightButton = UIBarButtonItem(title: "편집", style: UIBarButtonItem.Style.plain, target: self, action: #selector(table_controller.showEditing(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        if(timer2 != nil){timer2.invalidate()}
        timer2 = Timer(timeInterval: 0.05, target: self, selector: #selector(table_controller.timerDidFire2), userInfo: nil, repeats: true)
        RunLoop.current.add(timer2, forMode: RunLoop.Mode.common)
        
        if(timer3 != nil) {timer3.invalidate()}
        timer3 = Timer(timeInterval: 2.0, target: self, selector: #selector(table_controller.timerDidFire3), userInfo: nil, repeats: true)
        RunLoop.current.add(timer3, forMode: RunLoop.Mode.common)
        
        table_controller.right_now_refresh = 1
        timerDidFire3()
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
    
    func list_refresh(){
        add_check_change()
        tableview.reloadData()
    }
    
    //실시간으로 계속 돌아감
    @objc func timerDidFire2(){
        if timeCount > 0{timeCount -= 0.05}
        time_pro.progress = Float(timeCount)/7
        if table_controller.right_now_refresh == 1{
            table_controller.right_now_refresh = 0
            scan_all_ticker()
            //프로그래스바 끄기
            time_pro.isHidden = true
            //환율 계산 변경
            let gettext2 = String(describing: defaults!.object(forKey: "money_v") ?? "")
            if gettext2 == "" || gettext2 == "0"{
                table_controller.usd = table_controller.usd_r
                table_controller.jpy = table_controller.jpy_r
            }else{
                table_controller.usd = table_controller.usd_f
                table_controller.jpy = table_controller.jpy_f
            }
            list_refresh()
        }
    }
    
    //프리미엄 이름 변경됐을시 새로고침 해줘야함
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
                if primium_change == "Binance"{self.pri_text.setTitle("Binance", for: UIControl.State.normal)}
                if primium_change == "Gateio"{self.pri_text.setTitle("Gateio", for: UIControl.State.normal)}
                if primium_change == "Cexio"{self.pri_text.setTitle("Cexio", for: UIControl.State.normal)}
                
                save_primium()
                save_kind()
                primium = []
                scan_all_ticker()
                self.list_refresh()
            }
        }
    }
    
    //테이블 코드 시작--------------------------------------------------------------
    
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
                save_arr()
                section_change = []
                self.list_refresh()
                alertView.dismissAlertView()
            })
            dialog.show()
        }
    }
    
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
        func add_dialog(w1:String,w2:String){
            dialog.addButton(w1, hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
                alertView.dismissAlertView()
                table_controller.send_data[1] = w2
                self.navigationController?.pushViewController(secondViewController, animated: true)
            })
        }
        if bithumb_ex.contains(">" + table_controller.send_data[0] + "/"){
            add_dialog(w1: "BITHUMB",w2: "Bithumb")
        }
        if bitfinex_ex.contains(">" + table_controller.send_data[0] + "/"){
            add_dialog(w1: "BITFINEX",w2: "BitFinex")
        }
        if binance_ex.contains(">" + table_controller.send_data[0] + "/"){
            add_dialog(w1: "BINANCE",w2: "Binance")
        }
        dialog.show()
        if bittrex_ex.contains(">" + table_controller.send_data[0] + "/"){
            add_dialog(w1: "BITTREX",w2: "BitTrex")
        }
        if poloniex_ex.contains(">" + table_controller.send_data[0] + "/"){
            add_dialog(w1: "POLONIEX",w2: "Poloniex")
        }
        if korbit_ex.contains(">" + table_controller.send_data[0] + "/"){
            add_dialog(w1: "KORBIT",w2: "Korbit")
        }
    }
    //헤더 높이
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 37
            //return CGFloat.leastNormalMagnitude
        }
        return 37
        //return tableView.sectionHeaderHeight
    }
    //커스템 섹션 헤더
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
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "coincell2", for: indexPath) as! coincell2
        //단위
        cell.name2.text = section_change2[indexPath.section][indexPath.row][5]

        //코인 이름 저장
        //cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        cell.coin_name.text = section_change2[indexPath.section][indexPath.row][0]
        
        //거래소 이름 저장
        cell.change.text = section_change2[indexPath.section][indexPath.row ][1]
        
        //가격 저장
        let pricee = section_change2[indexPath.section][indexPath.row ][2]
        if !(Float(pricee) == nil){
            //원화-------------
            //0보다 작은지 확인
            var tmpp = pricee
            if tmpp.contains("."){
               tmpp = tmpp.components(separatedBy: ".")[0]
            }
            //1원 일 경우 소수점 필요하니까 아래 작업
            var price_krw = coma(str: tmpp)
            if (tmpp.count < 3){//3자리 이내
                price_krw = pricee
            }
            cell.price.textColor = UIColor.black
            cell.price.text = price_krw + "원"

            //달러-------------
            var price_tmp = String(Float(pricee)! / Float(table_controller.usd)!)
            let tmp_usd = round(Float(price_tmp)! * pow(10.0, Float(3))) / pow(10.0, Float(3))
            var price_usd = coma(str: String(tmp_usd))
            if (Float(price_usd) == 0){
                price_usd = price_tmp
            }
            //엔화-------------
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
               cell.price_sub.text = price_usd + "달러"
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
                cell.price.text = "로딩중"
            }else if pricee == "미지원"{
                cell.price.text = "미지원"
            }else{
                cell.price.text = "오류"
            }
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
                cell.before.text = "미지원"
            }else{
                cell.before.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
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
        if (primium.count > 0) && !(Float(pricee) == nil) && pricee != "---" && ((primium.contains {$0.contains(compare)})){
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
                        break
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
            cell.primium.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.1)
            cell.primium.textColor = UIColor.gray
            if pricee == "---"{
                cell.primium.text = "로딩중"//로딩중
            }else if pricee == "미지원"{
                cell.primium.text = "미지원"
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

    //------------------------------------------------------------
    
    //코인추가 팝업
    @objc func add_coin(_ button:UIBarButtonItem!){
        var dialog = SelectionDialog(title: "코인 추가", closeButtonTitle: "닫기")
        func add_w_item(str:String){
            dialog.addItem(item: str, didTapHandler: { () in
                dialog.close()
                choose_coin(kind: str)
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
    
    @IBAction func select_kind_price(_ sender: Any) {
        
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        is_scroll = 1
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        is_scroll = 0
    }
}

enum Example {
    case helloWorld, candleStick
}

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
