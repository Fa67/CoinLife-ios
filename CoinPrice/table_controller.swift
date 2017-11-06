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
import GoogleMobileAds

var coin_kind: [[String]] = []//여기에 걍 막 저장
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
}

class addcell: UITableViewCell {
     @IBOutlet weak var GoogleBannerView: GADBannerView!
}

class table_controller: UITableViewController , UIViewControllerPreviewingDelegate {
   
  var section_cnt = 0
    
    
    private var previewingViewController: UIViewController?
    
    @IBOutlet weak var pri_text: UIButton!
    var is_scroll = 0
    static var usd = "0"//환율
    static var cny = "0"//환율
    static var jpy = "0"//환율
    var timeCount:Float = 10 //5초마다 갱신
    var timer:Timer! , timer2:Timer! , timer3:Timer!
    @IBOutlet weak var time_pro: UIProgressView!//상단 새로고침 현황
    static var send_data = ["0","0","0","0","0"]//차트 컨트롤로에서 참고할 변수
    
    @IBAction func primium_s(_ sender: Any) {add_pri()}
    @IBOutlet weak var tableview: UITableView!
    
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
 
        /*
        GoogleBannerView.adUnitID = "ca-app-pub-0355430122346055/1529226484"
        GoogleBannerView.rootViewController = self
        GoogleBannerView.load(GADRequest())
     */
        
        load_arr()
        load_primium()
        load_kind()
        
        list_refresh()
        scan_all()
        //self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.clipsToBounds = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        registerForPreviewing(with: self, sourceView: tableview)
        //self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        time_pro.transform = time_pro.transform.scaledBy(x: 1, y: 1)//프로그래스 두껍게
        ZAlertView.positiveColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
        ZAlertView.negativeColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
        
        //let leftButton: UIBarButtonItem = UIBarButtonItem(title: "프리미엄 기준 : Poloniex", style: UIBarButtonItemStyle.done, target: self, action: #selector(table_controller.add_coin(_:)))
        //self.navigationItem.leftBarButtonItem = leftButton
        //let rightButton: UIBarButtonItem = UIBarButtonItem(title: "추가", style: UIBarButtonItemStyle.done, target: self, action: #selector(table_controller.add_coin(_:)))
        
        /*
        let icon = UIImage(named: "add")
        let iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20))
        let iconButton = UIButton(frame: iconSize)
        iconButton.setBackgroundImage(icon, for: .normal)
        let barButton = UIBarButtonItem(customView: iconButton)
        iconButton.addTarget(self, action: #selector(table_controller.add_coin(_:)), for: .touchUpInside)
        iconButton.contentMode = UIViewContentMode.scaleAspectFit*/
        //self.navigationItem.leftBarButtonItem = barButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(table_controller.add_coin(_:)))
        

        var rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(table_controller.showEditing(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let url = URL(string: "https://search.naver.com/p/csearch/content/apirender_ssl.nhn?_callback=a&pkid=141&key=exchangeApiNationOnly&where=nexearch&q=1%EB%8B%AC%EB%9F%AC&u1=keb&u6=standardUnit&u7=0&u3=USD&u4=KRW&u5=info&u2=1")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            //print(parset)
            //table_controller.usd = (parset?.components(separatedBy: "\"KRW\":")[1].components(separatedBy: "}")[0])!
            table_controller.usd = (parset?.components(separatedBy: "\"price\" : \"")[2].components(separatedBy: "\"")[0].replacingOccurrences(of: ",", with: ""))!
            
        }
        task.resume()
        
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
    
    @objc func showEditing(_ button:UIBarButtonItem!)
    {
        if(self.tableView.isEditing == true)
        {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        else
        {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "Done"
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
                    ticker_coinone()
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
        //print(section_change)
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
    
    @objc func timerDidFire(){
        scan_all()
        timeCount = 10.0
    }
    
    @objc func timerDidFire2(){
        if timeCount > 0{timeCount -= 0.05}
        time_pro.progress = Float(timeCount)/10
    }
    
    @objc func timerDidFire3(){
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
                primium = []
                self.scan_all()
                self.list_refresh()
            }
            
            
        }
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
        return true
    }
    //제거 눌렀을때
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            for i in 0...coin_kind.count - 1 {
                if(section_change2[indexPath.section][indexPath.row][0].contains(coin_kind[i][0])
                    && section_change2[indexPath.section][indexPath.row][1].contains(coin_kind[i][1])){
                    coin_kind.remove(at: i)
                    break
                }
            }
            save_arr()
            section_change = []
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)!
        header.textLabel?.textColor = UIColor.gray
        //header.backgroundColor = UIColor.gray
    }
   
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if -1 == indexPath.row{
            section_cnt = section_cnt + 1
            
            let cell2 = tableview.dequeueReusableCell(withIdentifier: "addcell", for: indexPath) as! addcell
            
            if cell2.GoogleBannerView.adUnitID == nil{
                cell2.GoogleBannerView.adUnitID = "ca-app-pub-0355430122346055/1529226484"
                cell2.GoogleBannerView.rootViewController = self
                cell2.GoogleBannerView.load(GADRequest())
            }
            
            
            return cell2
        }else{
            
            let cell = tableview.dequeueReusableCell(withIdentifier: "coincell2", for: indexPath) as! coincell2
            
            //코인 이름 저장
            cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
            cell.coin_name.text = section_change2[indexPath.section][indexPath.row][0]
            
            //거래소 이름 저장
            cell.change.text = section_change2[indexPath.section][indexPath.row ][1]
            
            //가격 이름 저장
            var pricee = section_change2[indexPath.section][indexPath.row ][2]
            if !(Float(section_change2[indexPath.section][indexPath.row ][2]) == nil){
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
                    price_tmp = String(Float(pricee)! / Float(table_controller.usd)!)
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
        let dialog2 = ZAlertView(title: kind, message: "등록이 안될 시 세글자로 시도해주세요.\n QTUM -> QTM", isOkButtonLeft: false, okButtonText: "추가", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
            let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("coin_choose")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
            if !get_tmp.contains("@") && !get_tmp.contains("#") && !(get_tmp == ""){
                coin_kind.append([get_tmp.uppercased(), kind,"---","---"])
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
    
    
    /*
    func load_arr(){
        let file = "/save.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let gettext = try String(contentsOf: fileURL, encoding: .utf8)
                var tmp: [String] = []
                tmp = gettext.components(separatedBy: "#")
                for i in 0...tmp.count - 2 {
                    coin_kind.append([tmp[i].components(separatedBy: "@")[0], tmp[i].components(separatedBy: "@")[1],"---","---"])
                }
            }
            catch {}
        }
    }*/
    
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
            coin_kind.append([tmp[i].components(separatedBy: "@")[0], tmp[i].components(separatedBy: "@")[1],"---","---"])
        }
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }

    func save_arr() {
        var text = ""
        for i in 0...coin_kind.count - 1 {
            text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "#")
        }
        
        
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(text), forKey: "arr")
        defaults?.synchronize()
    }
    /*
    func save_arr(){
        let file = "/save.txt"
        var text = ""
        for i in 0...coin_kind.count - 1 {
            text.append( coin_kind[i][0] + "@" + coin_kind[i][1] + "#")
        }
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try text.write(to: fileURL, atomically: false, encoding:.utf8)
            }
            catch {}
        }
*/
    /*
    func load_primium(){
        let file = "/primium.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let gettext = try String(contentsOf: fileURL, encoding: .utf8)
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
 }*/
    
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
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }
        
    func save_primium() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(primium_change), forKey: "primium")
        defaults?.synchronize()
    }
    
        /*
    func save_primium(){
        let file = "/primium.txt"
        let text = primium_change
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try text.write(to: fileURL, atomically: false, encoding:.utf8)
            }
            catch {}
        }
    }
    */
    
    /*
    func load_kind(){
        let file = "/kind.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let gettext = try String(contentsOf: fileURL, encoding: .utf8)
                kind_price=gettext
            }
            catch {}
        }
    }
    */
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
      /*
    func save_kind(){
        
      
        let file = "/kind.txt"
        let text = kind_price
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try text.write(to: fileURL, atomically: false, encoding:.utf8)
            }
            catch {}
        }
    }*/
    
    @IBAction func select_kind_price(_ sender: Any) {
        let dialog = ZAlertView(title: "표시 단위 : " + kind_price, message: nil, alertType: ZAlertView.AlertType.multipleChoice)
        dialog.addButton("원(KRW)", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "KRW"
            self.save_kind()
            self.list_refresh()
        })
        dialog.addButton("달러(USD)", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "USD"
            self.save_kind()
            self.list_refresh()
        })
        dialog.show()
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
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        is_scroll = 1
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        is_scroll = 0
    }
    
}






