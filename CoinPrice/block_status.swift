//
//  block_status.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 25..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import Foundation

class coincell3: UITableViewCell {
    @IBOutlet weak var coin_name: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var coin_image: UIImageView!
}

class block_status: UITableViewController {
    
    let images = ["btc","bch","eth","etc","ltc","dash","xmr","zec"]
    var data: [[String]] = [["BTC","---","---"],["BCH","---","---"],["ETH","---","---"],
                            ["ETC","---","---"],["LTC","---","---"],["DASH","---","---"],
                            ["XMR","---","---"],["ZEC","---","---"]]
    var timer:Timer!

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
    
    @objc func reload(_ button:UIBarButtonItem!){
        for i in 0...6{
            data[i][1] = "---"
            data[i][2] = "---"
        }
        
        let url = URL(string: "https://bitinfocharts.com/")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            let parset = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            //print(parset)
            self.data[0][2] = (parset?.components(separatedBy: "<a href=\"comparison/bitcoin-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[1][2] = (parset?.components(separatedBy: "<a href=\"comparison/bitcoin cash-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[2][2] = (parset?.components(separatedBy: "<a href=\"comparison/ethereum-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[3][2] = (parset?.components(separatedBy: "<a href=\"comparison/ethereum classic-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[4][2] = (parset?.components(separatedBy: "<a href=\"comparison/litecoin-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[5][2] = (parset?.components(separatedBy: "<a href=\"comparison/dash-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[6][2] = (parset?.components(separatedBy: "<a href=\"comparison/monero-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            self.data[7][2] = (parset?.components(separatedBy: "<a href=\"comparison/zcash-confirmationtime.html\">")[1].components(separatedBy: "<")[0])!
            
            let tmp = (parset?.components(separatedBy: "Blocks Count </td>")[1])
            self.data[0][1] = (tmp!.components(separatedBy: "<td class=\"coin c_btc\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[1][1] = (tmp!.components(separatedBy: "<td class=\"coin c_bch\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[2][1] = (tmp!.components(separatedBy: "<td class=\"coin c_eth\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[3][1] = (tmp!.components(separatedBy: "<td class=\"coin c_etc\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[4][1] = (tmp!.components(separatedBy: "<td class=\"coin c_ltc\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[5][1] = (tmp!.components(separatedBy: "<td class=\"coin c_dash\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[6][1] = (tmp!.components(separatedBy: "<td class=\"coin c_xmr\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            self.data[7][1] = (tmp!.components(separatedBy: "<td class=\"coin c_zec\"")[1].components(separatedBy: ">")[1].components(separatedBy: "<")[0])
            
        }
        task.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(block_status.reload(_:)))
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        self.reload(nil)
        
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 2.0, target: self, selector: #selector(table_controller.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)

    }
    

    @objc func timerDidFire(){
        tableview.reloadData()
        tableview.dataSource = self
        tableview.delegate = self
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

        return data.count
    }
    
    //테이블 데이터 로드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "coincell3", for: indexPath) as! coincell3
        
        //코인 이름 저장
        cell.coin_name.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        cell.coin_name.text = data[indexPath.row][0]
        
        cell.count.text = data[indexPath.row][1]
        
        cell.time.text = data[indexPath.row][2]
        cell.coin_image.image = UIImage(named: images[indexPath.row])

        return cell
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


