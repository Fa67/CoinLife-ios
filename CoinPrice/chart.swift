//
//  chart.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 16..
//  Copyright © 2017년 jungho. All rights reserved.
//

import Foundation
import UIKit
import SwiftChart
import NVActivityIndicatorView

var tmppp = ""
var dataa = ["---","---","---","---","---","---"]
var usbtc = Float(0.0)
var bid: [String] = []
var bidmax = Float(0)
var ask: [String] = []
var askmax = Float(0)
var order_loading_b = false
var order_loading_a = false

class askcell: UITableViewCell {
    @IBOutlet weak var price_ask: UILabel!
    @IBOutlet weak var amount_ask: UILabel!
    
    @IBOutlet weak var view_bid: UIView!
    @IBOutlet weak var price_bid: UILabel!
    @IBOutlet weak var amount_bid: UILabel!
    @IBOutlet weak var view_ask: UIView!
    @IBOutlet weak var leftt: NSLayoutConstraint!
    @IBOutlet weak var right: NSLayoutConstraint!
}

class buycell: UITableViewCell {
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amount: UILabel!
    
}

class chart: UITableViewController, ChartDelegate  , NVActivityIndicatorViewable  {
  
 
    
    var tmp_max = Float(0)
    @IBOutlet weak var asktable: UITableView!
    //@IBOutlet weak var bidtable: UITableView!
    @IBAction func segment_(_ sender: Any) {
        let size = CGSize(width: 30, height: 30)
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: 1)!)
        time_check = segment_wow.selectedSegmentIndex + 2
        is_allow_chart.text = ""
        tmppp = ""
        check = 0
        chart.removeAllSeries()
        getdata()
    }
    @IBOutlet weak var segment_wow: UISegmentedControl!
    
    @IBOutlet weak var is_allow_chart: UILabel!
    var dateSt = ""
    var dateSt_now = ""
    var timer:Timer!
    var timer2:Timer!
    var check = 0
    var periods = ""
    @IBOutlet weak var past: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var coin_change: UILabel!
    @IBOutlet weak var price_chart: UILabel!
    @IBOutlet weak var before_chart: UILabel!
    var selectedChart = 0
    var time_check = 3
    
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var label: UILabel!
    
    fileprivate var labelLeadingMarginInitialConstant: CGFloat!
    
    @objc func candle(_ button:UIBarButtonItem!){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "candle") as! candle
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    override func viewDidLoad() {
        let size = CGSize(width: 30, height: 30)
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: 1)!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5) {
            //NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
            self.stopAnimating()
        }
        
        is_allow_chart.text = ""
        
        ask = []
        bid = []
        bidmax = Float(0)
        askmax = Float(0)
        self.title = table_controller.send_data[0]
        
        tmppp = ""
        coin_change.text = table_controller.send_data[1]
        price_chart.font = UIFont(name:"HelveticaNeue-Bold", size: 33.0)
        
        dataa[0] = table_controller.send_data[2]//현재가
        dataa[1] = table_controller.send_data[3]//전일대비
        dataa[2] = "---"//전일가
        dataa[3] = "---"//고가
        dataa[4] = "---"//저가
        dataa[5] = "---"//거래량
        
        
        
        getdata()
        timerDidFire2()

        let rightButton = UIBarButtonItem(title: "해외 봉 차트", style: UIBarButtonItemStyle.plain, target: self, action: #selector(candle(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        
        
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 10.0, target: self, selector: #selector(table_controller.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        
        if(timer2 != nil){timer.invalidate()}
        timer2 = Timer(timeInterval: 1.0, target: self, selector: #selector(table_controller.timerDidFire2), userInfo: nil, repeats: true)
        RunLoop.current.add(timer2, forMode: RunLoopMode.commonModes)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool){
        
    }
    
    @objc func timerDidFire(){
        getdata()
    }
    
    func coma(str:String) ->String{
        var tmpp = str
        if tmpp.contains("."){
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
        return made_price
    }
    
    @objc func timerDidFire2(){
        
        if order_loading_b == false && order_loading_a == false{
            asktable.reloadData()
            asktable.dataSource = self
            asktable.delegate = self
        }
        
        //asktable.register(UITableViewCell.self, forCellReuseIdentifier: "askcell")
        
        //bidtable.reloadData()
        //bidtable.dataSource = self
        //bidtable.delegate = self
        //bidtable.register(UITableViewCell.self, forCellReuseIdentifier: "buycell")
        
        if !(tmppp == "") && check == 0 && !(check == -2){
            check = 1;
            initializeChart()
        }
        //현재가
        if !(dataa[0] == "미지원"){
            let made_price = coma(str: dataa[0])
            price_chart.text = made_price + ""
            
        }else{
            price_chart.text = "---"
        }
        
        //전일대비
        if !(dataa[1] == "미지원"){
            before_chart.text = dataa[1] + "%"
            let tmp2 = Float(dataa[1])
            if !(tmp2 == nil){
                if tmp2! > Float(0)   {
                    before_chart.textColor = UIColor(red: 70/255, green: 170/255, blue: 70/255, alpha: 1.0)
                }else if  tmp2! < Float(0) {
                    before_chart.textColor = UIColor(red: 200/255, green: 70/255, blue: 70/255, alpha: 1.0)
                }else{
                    before_chart.textColor = UIColor.gray
                }
            }
        }else{
            before_chart.textColor = UIColor.gray
            before_chart.text = "---"
        }
        

        if !(dataa[2] == "미지원" || dataa[2] == "---"){
            past.text = coma(str: dataa[2])
            
        }else{
            past.text = dataa[2]//전일가
        }
        if !(dataa[3] == "미지원" || dataa[2] == "---"){
            high.text = coma(str: dataa[3])
            
        }else{
            high.text = dataa[3]//전일가
        }
        if !(dataa[4] == "미지원" || dataa[2] == "---"){
            low.text = coma(str: dataa[4])
            
        }else{
            low.text = dataa[4]//전일가
        }
        
 
        if dataa[5].contains("."){
            dataa[5] = dataa[5].components(separatedBy: ".")[0]
        }
        amount.text = dataa[5]//거래량
    }
    
    func getdata(){
        var yesterday = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
        if time_check == 2{
            periods = "60"
            yesterday = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
        }
        if time_check == 3{
            periods = "300"
            yesterday = Calendar.current.date(byAdding: .hour, value: -10, to: Date())
        }
        if time_check == 4{
            periods = "900"
            yesterday = Calendar.current.date(byAdding: .hour, value: -30, to: Date())
        }
        if time_check == 5{
            periods = "1800"
            yesterday = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        }
        if time_check == 6{
            periods = "3600"
            yesterday = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }
        if time_check == 7{
            periods = "21600"
            yesterday = Calendar.current.date(byAdding: .day, value: -60, to: Date())
        }
        
        
        /*let yes_t = (yesterday?.description.components(separatedBy: " ")[0] + " " + yesterday?.description.components(separatedBy: " ")[1])
         let dfmatter = DateFormatter()
         dfmatter.locale = NSLocale.current
         dfmatter.dateFormat="yyyy-MM-dd hh:mm:ss"
         let dateee = dfmatter.date(from: (yesterday?.description)!)*/
        let dateStamp:TimeInterval = yesterday!.timeIntervalSince1970
        dateSt = (Int(dateStamp)).description
        
        let now = Calendar.current.date(byAdding: .minute, value: 0, to: Date())
        let dateStamp2:TimeInterval = now!.timeIntervalSince1970
        dateSt_now = (Int(dateStamp2)).description
        
        if (table_controller.send_data[1] == "Bithumb"){
            chart_bithumb(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "Coinone"){
            chart_coinone(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "Poloniex"){
            chart_poloniex(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "BitFinex"){
            chart_bitfinex(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "BitTrex"){
            chart_bittrex(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "Korbit"){
            chart_korbit(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "Coinnest"){
            chart_coinnest(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "Huobi"){
            chart_huobi(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "Okcoin"){
            chart_okcoin(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
        else if (table_controller.send_data[1] == "BitFlyer"){
            chart_bitflyer(dateSt: dateSt,dateSt_now: dateSt_now,periods: periods)
        }
    }
    
   
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stopAnimating()
        timer?.invalidate()
        timer = nil
        timer2?.invalidate()
        timer2 = nil
    }
    
    func initializeChart() {
        chart.delegate = self
        
        var month_cnt:Int = -1
        var serieData: [Float] = []
        var labels: [Float] = []
        var labelsAsString: Array<String> = []
        
        
        
        if !tmppp.contains("["){
            print(tmppp)
            is_allow_chart.text = "미지원 차트 입니다."
            self.stopAnimating()
            check = -2
            return
        }
        let datee = tmppp.components(separatedBy: "[")
        if (datee.count < 10){
            print(tmppp)
            is_allow_chart.text = "미지원 차트 입니다."
            self.stopAnimating()
            check = -2
            return
        }
        is_allow_chart.text = ""
        for i in 2...datee.count - 3 {
            let date_f = datee[i].components(separatedBy: ",")[0]
            if date_f == ""{
                continue
            }
            //date_f = date_f.replacingOccurrences(of: " ", with: "")
            let date = Date(timeIntervalSince1970: Double(date_f)!)
            let dateFormatter = DateFormatter()
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.locale = NSLocale.current
            if time_check == 2{
                dateFormatter.dateFormat = "hh"
            }
            else if time_check == 3{
                dateFormatter.dateFormat = "hh"
            }
            else if time_check == 4{
                dateFormatter.dateFormat = "hh"
            }
            else if time_check == 5{
                dateFormatter.dateFormat = "dd"
            }
            else if time_check == 6{
                dateFormatter.dateFormat = "dd"
            }
            else if time_check == 7{
                dateFormatter.dateFormat = "MM"
            }
            
            var strDate = dateFormatter.string(from: date)
            //print(strDate)
            if (strDate.contains("시")){
                strDate = strDate.components(separatedBy: "시")[0]
            }
            if (strDate.contains("일")){
                strDate = strDate.components(separatedBy: "일")[0]
            }
            if (strDate.contains("월")){
                strDate = strDate.components(separatedBy: "월")[0]
            }
            
            let vaule_t = datee[i].components(separatedBy: ",")[4]
            if vaule_t == ""{
                continue
            }
            if (Float(vaule_t) == 0){
                continue
            }
            
            let value_f = vaule_t
            if (table_controller.send_data[1] == "BitTrex") || (table_controller.send_data[1] == "Poloniex"){
                if table_controller.send_data[0] == "BTC"{
                    serieData.append( Float(value_f)!  * Float(table_controller.usd)!)
                }else{
                    serieData.append( Float(value_f)!  * Float(table_controller.usd)! * usbtc)
                }
            }else if (table_controller.send_data[1] == "BitFinex") {
                serieData.append( Float(value_f)!  * Float(table_controller.usd)!)
            }
            else if (table_controller.send_data[1] == "BitFlyer"){
                serieData.append( Float(value_f)!  * Float(table_controller.jpy)! * 0.01)
            }
            else{
                 serieData.append( Float(value_f)! )
            }
            
            if month_cnt == -1 || !(month_cnt == Int(strDate)!){
                if (time_check == 6) || (time_check == 3){
                    if (Int(strDate)! % 2 != 0){
                        continue
                    }
                }
                if (time_check == 4){
                    if (Int(strDate)! % 4 != 0){
                        continue
                    }
                }
                month_cnt = Int(strDate)!
                labels.append(Float(i))
                //labelsAsString.append("")
                if (time_check == 5) || (time_check == 6){
                    labelsAsString.append(strDate + "일")
                }
                else if (time_check == 2) || (time_check == 3) || (time_check == 4){
                    labelsAsString.append(strDate + "시")
                }
                else if (time_check == 7){
                    labelsAsString.append(strDate + "월")
                }else{
                    labelsAsString.append(strDate)
                }
                
            }
        }
        let series = ChartSeries(serieData)
        series.area = true
        
        chart.lineWidth = 1.2
        chart.labelFont = UIFont.systemFont(ofSize: 11)
        chart.xLabels = labels
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return labelsAsString[labelIndex]
        }
        //chart.showXLabelsAndGrid = true
        //chart.xLabelsSkipLast = true
        chart.xLabelsTextAlignment = .center
        chart.yLabelsOnRightSide = true
        // Add some padding above the x-axis
        chart.minY = serieData.min()! - 5
        chart.removeAllSeries()
        chart.add(series)
        self.stopAnimating()
    }
    
    // Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        if check == -2 || check == -1 || !(is_allow_chart.text == ""){
            return
        }
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            label.text = numberFormatter.string(from: NSNumber(value: value))
        
            // Align the label to the touch left position, centered
            var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
            
            // Avoid placing the label on the left of the chart
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - label.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }
            labelLeadingMarginConstraint.constant = constant
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        label.text = ""
        labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        //label.text = ""
        //labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        order_loading_b = true
        order_loading_a = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        order_loading_b = false
        order_loading_a = false
    }
   
    
    //섹션 별 개수 가져오기
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.asktable{
            count = bid.count
        }
        
        
        
        return count!
    }
    
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        
        if bidmax > askmax{
            tmp_max = bidmax
        }else{
            tmp_max = askmax
        }
        
        /*
        if (tableView == self.bidtable){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "buycell", for: indexPath) as! buycell
            if ask.count - 1 < indexPath.row{
                cell.price.text = "error"
                cell.amount.text = "error"
                return cell
            }
            
            var tmp_price = ""
            if (table_controller.send_data[1] == "BitTrex") || (table_controller.send_data[1] == "Poloniex"){
                if table_controller.send_data[0] == "BTC"{
                    tmp_price = ( Double(ask[indexPath.row].components(separatedBy: ",")[0])!  * Double(table_controller.usd)!).description
                    //print(tmp_price)
                }else{
                    tmp_price = ( Double(ask[indexPath.row].components(separatedBy: ",")[0])!  * Double(table_controller.usd)! * Double(usbtc)).description
                }
            }else if (table_controller.send_data[1] == "BitFinex") {
                tmp_price = ( Double(ask[indexPath.row].components(separatedBy: ",")[0])!  * Double(table_controller.usd)!).description
            }else{
                tmp_price = ask[indexPath.row].components(separatedBy: ",")[0]
            }
            if tmp_price.contains("."){
                tmp_price = tmp_price.components(separatedBy: ".")[0]
            }
            
            cell.price.text = tmp_price
            cell.amount.text = ask[indexPath.row].components(separatedBy: ",")[1]
            let alp = Float(ask[indexPath.row].components(separatedBy: ",")[1])!/Float(tmp_max)
            cell.contentView.backgroundColor = UIColor(red: 0/255, green: 151/255, blue: 167/255, alpha: CGFloat(alp))
            
            
            return cell
        }*/
        if (tableView == self.asktable){
            let cell = tableView.dequeueReusableCell(withIdentifier: "askcell", for: indexPath) as! askcell
            if bid.count - 1 < indexPath.row{
                cell.price_ask.text = "error"
                cell.amount_ask.text = "error"
                return cell
            }
            var tmp_amount = bid[indexPath.row ].components(separatedBy: ",")[1]
            var tmp_price = Double(bid[indexPath.row].components(separatedBy: ",")[0])
            if (table_controller.send_data[1] == "BitTrex") || (table_controller.send_data[1] == "Poloniex"){
                if table_controller.send_data[0] == "BTC"{
                    tmp_price = ( tmp_price!  * Double(table_controller.usd)!)
                }else{
                    tmp_price = ( tmp_price!  * Double(table_controller.usd)! * Double(usbtc))
                }
            }else if (table_controller.send_data[1] == "BitFinex") {
                tmp_price = ( tmp_price! * Double(table_controller.usd)!)
            }else if (table_controller.send_data[1] == "BitFlyer") {
                tmp_price = ( tmp_price! * Double(table_controller.jpy)! * 0.01)
            }
            
            //tmp_price = Double(Int(tmp_price!))
          
            
            cell.price_ask.text = Int(tmp_price!).description
            tmp_amount = (round(Float(tmp_amount)! * pow(10.0, Float(2))) / pow(10.0, Float(2))).description
            cell.amount_ask.text = tmp_amount
            var alp = Float(bid[indexPath.row].components(separatedBy: ",")[1])!/Float(tmp_max)
            //cell.amount_ask.text = ""
            //cell.view_ask.backgroundColor = UIColor(red: 0/255, green: 151/255, blue: 167/255, alpha: CGFloat(alp))
            //cell.view_ask.frame.size.width =  CGFloat(Float(cell.width) * alp * 0.5)
            //cell.view_ask.frame = CGRect(x: 0, y: 0, width: cell.view_ask.frame.width * CGFloat(alp), height: cell.view_ask.frame.height)
            cell.leftt.constant = CGFloat(Float(cell.view_ask.frame.size.width) * (1 - alp))
            
            
            if ask.count - 1 < indexPath.row{
                cell.price_bid.text = "error"
                cell.amount_bid.text = "error"
                return cell
            }
            tmp_amount = ask[indexPath.row].components(separatedBy: ",")[1]
            tmp_price = Double(ask[indexPath.row].components(separatedBy: ",")[0])
            if (table_controller.send_data[1] == "BitTrex") || (table_controller.send_data[1] == "Poloniex"){
                if table_controller.send_data[0] == "BTC"{
                    tmp_price = ( tmp_price! * Double(table_controller.usd)!)
                }else{
                    tmp_price = ( tmp_price!  * Double(table_controller.usd)! * Double(usbtc))
                }
            }else if (table_controller.send_data[1] == "BitFinex") {
                tmp_price = ( tmp_price!  * Double(table_controller.usd)!)
            }else if (table_controller.send_data[1] == "BitFlyer") {
                tmp_price = ( tmp_price!  * Double(table_controller.jpy)! * 0.01)
            }
            
            //tmp_price = Double(Int(tmp_price!))
            
            cell.price_bid.text = Int(tmp_price!).description
            tmp_amount = (round(Float(tmp_amount)! * pow(10.0, Float(2))) / pow(10.0, Float(2))).description
            cell.amount_bid.text = tmp_amount
            alp = Float(ask[indexPath.row].components(separatedBy: ",")[1])!/Float(tmp_max)
            //cell.view_bid.backgroundColor = UIColor(red: 0/255, green: 151/255, blue: 167/255, alpha: CGFloat(alp))
            cell.right.constant = CGFloat(Float(cell.view_bid.frame.size.width) * (1.0 - alp))
            
            return cell
        }
        return cell!
        
    }
    
    /*
    fileprivate func showExampleController(_ controller: UIViewController) {
        if let currentExampleController = showExampleController {
            currentExampleController.removeFromParentViewController()
            currentExampleController.view.removeFromSuperview()
        }
        addChildViewController(controller)
        view.addSubview(controller.view)
        showExampleController = controller
    }*/
    
}


