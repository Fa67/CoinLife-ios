//
//  wallet.swift
//  CoinPrice
//
//  Created by User on 2017. 11. 10..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import Foundation
import ZAlertView

class walletcell: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var image_coin: UIImageView!
    
    
    @IBOutlet weak var topcolor: UIView!
    
}

class wallet: UITableViewController {
    var is_scroll = 0
    var add_tmp_coin = ""
    var add_tmp_change = ""
    var timer:Timer!
    
    @IBOutlet weak var all_money: UILabel!
    var all_m = 0
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
    
    
    
    @objc func add_wallet(_ button:UIBarButtonItem!){
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
    }
    
    @objc func showEditing(_ button:UIBarButtonItem!)
    {
        if(self.tableView.isEditing == true){
            is_scroll = 0
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "편집"
        }
        else{
            is_scroll = 1
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "저장"
        }
    }
    
    func choose_coin(kind: String){
        let dialog2 = ZAlertView(title: kind, message: "코인 종류를 입력해주세요.", isOkButtonLeft: false, okButtonText: "다음", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
            let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("coin_choose")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
            if !get_tmp.contains("@") && !get_tmp.contains("#") && !(get_tmp == ""){
                self.add_tmp_coin = get_tmp.uppercased()
                self.add_tmp_change = kind
                //coin_kind.append([get_tmp.uppercased(), kind,"---","---","wallet"])
                self.choose_coin_amount()
            }else{
                let dialog = ZAlertView(title: "오류",message: "입력 값에 오류가 있습니다.",closeButtonText: "확인",closeButtonHandler: { alertView in alertView.dismissAlertView()})
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
        },cancelButtonHandler: { alertView in alertView.dismissAlertView()})
        dialog2.addTextField("coin_choose", placeHolder: "ex)BTC,BCH,ETH,ETC...")
        dialog2.show()
    }
    
    func choose_coin_amount(){
        let dialog2 = ZAlertView(title: "소유한 코인 수량을 입력해주세요.", message: "", isOkButtonLeft: false, okButtonText: "추가", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
            let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("choose_coin_amount")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
            
            let get_float = Double(get_tmp)
            //let get_zero = Double(0.0)
            if !get_tmp.contains("@") && !get_tmp.contains("#") && !(get_tmp == "") && get_float != nil {
                
                coin_kind.append([self.add_tmp_coin, self.add_tmp_change,"---","---","wallet"])
                coin_kind_wallet.append([self.add_tmp_coin, self.add_tmp_change, (Float(get_tmp)?.description)!,"---"])
                self.save_arr()
                self.save_arr2()
                self.scan_all()
                self.timerDidFire()
                
            }else{
                let dialog = ZAlertView(title: "오류",message: "입력 값에 오류가 있습니다.",closeButtonText: "확인",closeButtonHandler: { alertView in alertView.dismissAlertView()})
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
        },cancelButtonHandler: { alertView in alertView.dismissAlertView()})
        dialog2.addTextField("choose_coin_amount", placeHolder: "ex)34.1253")
        dialog2.show()
    }
    
    func save_arr() {
        var text = ""
        if !(coin_kind_wallet.count == 0){
            for i in 0...coin_kind_wallet.count - 1 {
                text.append( coin_kind_wallet[i][0] + "@" + coin_kind_wallet[i][1] + "@" + coin_kind_wallet[i][2] + "#")
            }
        }
        
        let defaults = UserDefaults(suiteName: "group.jungcode.coin_wallet")
        defaults?.set(String(text), forKey: "arr")
        defaults?.synchronize()
    }
    
    func save_arr2() {
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
    
    func load_arr() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin_wallet")
        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "arr") ?? "")
        
        if gettext == ""{
            return
        }
        
        var tmp: [String] = []
        tmp = gettext.components(separatedBy: "#")
        
        for i in 0...tmp.count - 2 {
            var tmpp_data = tmp[i].components(separatedBy: "@")
            coin_kind_wallet.append([tmpp_data[0], tmpp_data[1],tmpp_data[2],"---",])
            
        }
        //return String(describing: defaults!.object(forKey: "score") ?? "0")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "편집", style: UIBarButtonItemStyle.plain, target: self, action: #selector(wallet.showEditing(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(wallet.add_wallet(_:)))
        
        load_arr()
        timerDidFire()
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 2.0, target: self, selector: #selector(wallet.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        
    }
    
    
    @objc func timerDidFire(){
        if is_scroll == 0{
            all_m = 0
            tableview.reloadData()
            tableview.dataSource = self
            tableview.delegate = self
            if coin_kind_wallet.count == 0 {
                all_money.text = "총 자산 : " + coma(str:all_m.description)
            }
            
        }
        
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
            for i in 0...coin_kind.count - 1 {
                if(coin_kind_wallet[indexPath.row][0].contains(coin_kind[i][0])
                    && coin_kind_wallet[indexPath.row][1].contains(coin_kind[i][1])){
                    
                    if coin_kind[i].count == 5{
                        if (coin_kind[i][4] == "wallet"){
                            coin_kind.remove(at: i)
                            
                            break
                        }
                    }
                }
            }
            is_scroll = 0
            coin_kind_wallet.remove(at: indexPath.row)
            self.save_arr()
            self.save_arr2()
            self.timerDidFire()
           
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = coin_kind_wallet[sourceIndexPath.row]
        coin_kind_wallet.remove(at: sourceIndexPath.row)
        coin_kind_wallet.insert(movedObject, at: destinationIndexPath.row)
        save_arr()
        save_arr2()
    }
    //클릭 시
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    //섹션 별 개수 가져오기
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return coin_kind_wallet.count
    }
    
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "walletcell", for: indexPath) as! walletcell
        
        cell.coin_name.text = coin_kind_wallet[indexPath.row][0] + "/" + coin_kind_wallet[indexPath.row][1]
        cell.count.text = coin_kind_wallet[indexPath.row][2] + ""
        
        for i in 0...coin_kind.count - 1 {
            if (coin_kind[i][0] == coin_kind_wallet[indexPath.row][0]) && (coin_kind[i][1] == coin_kind_wallet[indexPath.row][1]){
                let tmp1 = Double(coin_kind[i][2])
                let tmp2 = Double(coin_kind_wallet[indexPath.row][2])
                if !(tmp1 == nil) && !(tmp2 == nil){
                    all_m = all_m + Int(tmp1! * tmp2!)
                    //print(coin_kind_wallet[indexPath.row][0])
                    cell.price.text = coma(str: (tmp1! * tmp2!).description) + "￦"
                    break
                }else{
                    cell.price.text = "---"
                }
                
            }
        }
        
        all_money.text = "총 자산 : " + coma(str:all_m.description)
        
        let image_ccc = UIImage(named: coin_kind_wallet[indexPath.row][0].lowercased())
        
       
        
        if !(image_ccc == nil){
            cell.image_coin.image = image_ccc
            cell.topcolor.backgroundColor = image_ccc?.getPixelColor(pos:CGPoint(x: (image_ccc?.size.width)!/2,y:50))
        }else{
            cell.image_coin.image = nil
            //cell.topcolor.backgroundColor
            cell.topcolor.backgroundColor = UIColor(red: 0/255, green: 151/255, blue: 167/255, alpha: 0.7)
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
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
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
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        is_scroll = 1
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        is_scroll = 0
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
