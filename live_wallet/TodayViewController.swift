//
//  TodayViewController.swift
//  live_wallet
//
//  Created by User on 2017. 11. 14..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import NotificationCenter

var coin_kind: [[String]] = []//여기에 걍 막 저장
var section_change: [String] = []//거래소 리스트


class walletcell: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var price: UILabel!

    @IBOutlet weak var coin_image: UIImageView!
    
    @IBOutlet weak var topcolor: UIView!
    
}


class TodayViewController: UIViewController, NCWidgetProviding {

    var timer:Timer!
    static var usd = "0"//환율
    @IBOutlet weak var tableview: UITableView!
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            //expanded
            
            var heightt = 0
            //heightt = heightt + section_change2.count * 25
            for i in 0...coin_kind.count - 1 {
                heightt = heightt + 110
            }
            //print(heightt)
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(heightt))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        // Do any additional setup after loading the view from its nib.
        load_arr()
        timerDidFire()
        scan_all()
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 2.0, target: self, selector: #selector(TodayViewController.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
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
        let defaults = UserDefaults(suiteName: "group.jungcode.coin_wallet")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "arr") ?? "")
        
        if gettext == ""{
            return
        }
        
        var tmp: [String] = []
        tmp = gettext.components(separatedBy: "#")
        
        coin_kind = []
        for i in 0...tmp.count - 2 {
            var tmpp_data = tmp[i].components(separatedBy: "@")
            coin_kind.append([tmpp_data[0], tmpp_data[1],"---",tmpp_data[2]])
            
        }
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }
    
    @objc func timerDidFire(){
        add_check_change()
        tableview.reloadData()
        tableview.dataSource = self
        tableview.delegate = self
        
    }
    
    
    
    func add_check_change(){
        if(!(coin_kind.count == 0)){
            for i in 0...coin_kind.count - 1 {
                if(!section_change.contains(coin_kind[i][1])){
                    section_change.append(coin_kind[i][1]);
                }
            }
            
        }
    }
   
    
    func scan_all(){
        if !(section_change.count == 0){
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
                if(section_change[i] == "Bithumb" ){
                    tmp_str = tmp_str + "bithumb"
                }
                if(section_change[i] == "Coinone" ){
                    tmp_str = tmp_str + "coinone"
                }
                if(section_change[i] == "Poloniex"){
                    tmp_str = tmp_str + "poloniex"
                }
                if(section_change[i] == "BitTrex" ){
                    tmp_str = tmp_str + "bittrex"
                }
                if(section_change[i] == "BitFinex" ){
                    tmp_str = tmp_str + "bitfinex"
                }
                if(section_change[i] == "Korbit" ){
                    tmp_str = tmp_str + "korbit"
                }
                if(section_change[i] == "Coinnest" ){
                    tmp_str = tmp_str + "coinnest"
                }
               
                if(section_change[i] == "BitFlyer" ){
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
    
    
}

extension TodayViewController: UITableViewDelegate,UITableViewDataSource {
    
    
    //섹션 별 개수 가져오기
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return coin_kind.count
    }
    
    //테이블 데이터 로드
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "walletcell", for: indexPath) as! walletcell
        
        cell.coin_name.text = coin_kind[indexPath.row][0] + "/" + coin_kind[indexPath.row][1]
        cell.count.text = coin_kind[indexPath.row][3] + ""
        
        /*
        for i in 0...coin_kind.count - 1 {
            if (coin_kind[i][0] == coin_kind_wallet[indexPath.row][0]) && (coin_kind[i][1] == coin_kind_wallet[indexPath.row][1]){
                let tmp1 = Double(coin_kind[i][2])
                let tmp2 = Double(coin_kind_wallet[indexPath.row][2])
                if !(tmp1 == nil) && !(tmp2 == nil){
                    cell.price.text = coma(str: (tmp1! * tmp2!).description) + "￦"
                }else{
                    cell.price.text = "---"
                }
                
            }
        }*/
        let tmp1 = Double(coin_kind[indexPath.row][2])
        let tmp2 = Double(coin_kind[indexPath.row][3])
        if !(tmp1 == nil) && !(tmp2 == nil){
            cell.price.text = coma(str: (tmp1! * tmp2!).description) + "￦"
        }else{
            cell.price.text = "---"
        }
        
        let image_ccc = UIImage(named: coin_kind[indexPath.row][0].lowercased())
        
        
        
        if !(image_ccc == nil){
            cell.coin_image.image = image_ccc
            cell.topcolor.backgroundColor = image_ccc?.getPixelColor(pos:CGPoint(x: (image_ccc?.size.width)!/2,y:50))
        }else{
            cell.coin_image.image = nil
            //cell.topcolor.backgroundColor
           
        }
        //print ((image_ccc?.size.width)!)
        
        return cell
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
    
    
}

extension UIImage {
    func areaAverage() -> UIColor {
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let context = CIContext(options: nil)
        let cgImg = context.createCGImage(CoreImage.CIImage(cgImage: self.cgImage!), from: CoreImage.CIImage(cgImage: self.cgImage!).extent)
        
        let inputImage = CIImage(cgImage: cgImg!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
        
        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    
}
