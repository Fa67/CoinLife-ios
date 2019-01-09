//
//  block_status.swift
//  CoinPrice
//
//  Created by User on 2017. 10. 25..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit
import Foundation
import ZAlertView

class setting: UITableViewController {
    let defaults = UserDefaults(suiteName: "group.jungcode.coin")

    @IBOutlet var notice_content: UILabel!
    @IBOutlet var notice_title: UILabel!
    @IBOutlet var version: UILabel!
    @IBOutlet weak var select_m_texrt: UILabel!
    @IBOutlet weak var cny_text: UILabel!
    @IBOutlet weak var jpy_text: UILabel!
    @IBOutlet weak var usd_text: UILabel!
    @IBOutlet weak var cny_cell: UITableViewCell!
    @IBOutlet weak var jpy_cell: UITableViewCell!
    @IBOutlet weak var usd_cell: UITableViewCell!
    @IBOutlet weak var money_v: UISwitch!
    @IBOutlet weak var progresson: UISwitch!
    @IBOutlet weak var cny_: UILabel!
    @IBOutlet weak var jpy_: UILabel!
    @IBOutlet weak var usd_: UILabel!
    @IBOutlet weak var pri_change_set: UILabel!
    @IBOutlet var tableview: UITableView!
    
    @IBAction func money_v_action(_ sender: Any) {
        if money_v.isOn{
            defaults?.set(String("1"), forKey: "money_v")
            usd_cell.contentView.alpha = 1
            jpy_cell.contentView.alpha = 1
            //cny_cell.contentView.alpha = 1
            usd_cell.isUserInteractionEnabled = true
            jpy_cell.isUserInteractionEnabled = true
            //cny_cell.isUserInteractionEnabled = true
            usd_text.text = table_controller.usd_r
            jpy_text.text = table_controller.jpy_r
            //cny_text.text = table_controller.cny_r
            table_controller.usd_f = table_controller.usd_r
            table_controller.jpy_f = table_controller.jpy_r
            //table_controller.cny_f = table_controller.cny_r
            defaults?.set(String(""), forKey: "money_usd_f")
            defaults?.set(String(""), forKey: "money_jpy_f")
            //defaults?.set(String(""), forKey: "money_cny_f")
            table_controller.right_now_refresh = 1
        }else{
            defaults?.set(String("0"), forKey: "money_v")
            usd_cell.contentView.alpha = 0.5
            jpy_cell.contentView.alpha = 0.5
            //cny_cell.contentView.alpha = 0.5
            usd_cell.isUserInteractionEnabled = false
            jpy_cell.isUserInteractionEnabled = false
            //cny_cell.isUserInteractionEnabled = false
            usd_text.text = table_controller.usd_r
            jpy_text.text = table_controller.jpy_r
            //cny_text.text = table_controller.cny_r
            table_controller.right_now_refresh = 1
        }
        defaults?.synchronize()
    }
    @IBAction func progresson_action(_ sender: Any) {
        if progresson.isOn{
             defaults?.set(String("1"), forKey: "progress_on")
        }else{
             defaults?.set(String("0"), forKey: "progress_on")
        }
        defaults?.synchronize()
        table_controller.right_now_refresh = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func viewWillAppear(_ animated: Bool){
        if (primium_change == ""){
            pri_change_set.text = "선택"
        }else{
            pri_change_set.text = primium_change
        }
        
        if (kind_price == ""){select_m_texrt.text = "달러(USD)"
        }else if (kind_price == "KRW"){select_m_texrt.text = "원(KRW)"}
        else if (kind_price == "USD"){select_m_texrt.text = "달러(USD)"}
        else if (kind_price == "JPY"){select_m_texrt.text = "엔(JPY)"}
        else if (kind_price == "ALL"){select_m_texrt.text = "원(KRW)/달러(USD)"}
        else if (kind_price == "WAHT"){select_m_texrt.text = "거래소별 단위"}
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section) row: \(indexPath.row)")
        /*if indexPath.section == 0 && indexPath.row == 0 {
            let dialog = ZAlertView(title: notice_title.text, message: notice_content.text, closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }*/
        if indexPath.section == 0 && indexPath.row == 1 {
            let dialog2 = ZAlertView(title: "원하는 값을 입력해주세요.", message: "", isOkButtonLeft: false, okButtonText: "입력", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
                let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("choose_coin_amount")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
                
                let get_float = Double(get_tmp)
                if !(get_tmp == "") && get_float != nil && Double(get_float!) > Double(0) {
                    self.usd_text.text = (get_float?.description)!
                    table_controller.usd_f = (get_float?.description)!
                    self.defaults?.set(String((get_float?.description)!), forKey: "money_usd_f")
                    table_controller.right_now_refresh = 1
                }else{
                    let dialog = ZAlertView(title: "오류",message: "입력 값에 오류가 있습니다.",closeButtonText: "확인",closeButtonHandler: { alertView in alertView.dismissAlertView()})
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
            },cancelButtonHandler: { alertView in alertView.dismissAlertView()})
            dialog2.addTextField("choose_coin_amount", placeHolder: "ex) 1097.12")
            dialog2.show()
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            let dialog2 = ZAlertView(title: "원하는 값을 입력해주세요.", message: "", isOkButtonLeft: false, okButtonText: "입력", cancelButtonText: "취소",okButtonHandler: { alertView in alertView.dismissAlertView()
                let get_tmp = String(describing: alertView.getTextFieldWithIdentifier("choose_coin_amount")).components(separatedBy: "text = '")[1].components(separatedBy: "'")[0]
                
                let get_float = Double(get_tmp)
                if !(get_tmp == "") && get_float != nil && Double(get_float!) > Double(0) {
                    self.usd_text.text = (get_float?.description)!
                    table_controller.usd_f = (get_float?.description)!
                    self.defaults?.set(String((get_float?.description)!), forKey: "money_jpy_f")
                    table_controller.right_now_refresh = 1
                }else{
                    let dialog = ZAlertView(title: "오류",message: "입력 값에 오류가 있습니다.",closeButtonText: "확인",closeButtonHandler: { alertView in alertView.dismissAlertView()})
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
            },cancelButtonHandler: { alertView in alertView.dismissAlertView()})
            dialog2.addTextField("choose_coin_amount", placeHolder: "ex) 1097.12")
            dialog2.show()
        }
        
        
        
        if indexPath.section == 1 && indexPath.row == 0 {
            add_pri()
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            select_money()
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "change_c") as! change_c
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            let dialog = ZAlertView(title: "면책조항", message: "본 개발자는 정보의 정확성을 보장하기 위해 합당한 조치를 취했으나 정확성을 보장하지 않으며, 발생할 수있는 손실이나 손해에 대해 책임을 지지 않습니다.", closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            //First get the nsObject by defining as an optional anyObject
            let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
            //Then just cast the object as a String, but be careful, you may want to double check for nil
            let version2 = nsObject as! String
            let dialog = ZAlertView(title: "버전", message: version2 + "\n\n오픈소스\nhttps://github.com/zelic91/ZAlertView\nhttps://github.com/gpbl/SwiftChart\nhttps://github.com/ninjaprox/NVActivityIndicatorView\nhttps://github.com/shoheiyokoyama/SYBlinkAnimationKit", closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        
        if indexPath.section == 2 && indexPath.row == 2 {
            UIPasteboard.general.string = "iveinvalue@gmail.com"
            let dialog = ZAlertView(title: "iveinvalue@gmail.com", message: "개발자의 이메일 주소가 클립보드에 복사되었습니다.", closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        
        if indexPath.section == 2 && indexPath.row == 3 {
            //let url = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1303352869?mt=8")!
            //UIApplication.shared.openURL(url)
            UIApplication.shared.openURL(NSURL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1303352869?mt=8")! as URL)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version2 = nsObject as! String
        version.text = version2
        
        tableview.dataSource = self
        tableview.delegate = self
        
        //cny_.text = table_controller.cny
        usd_.text = table_controller.usd
        jpy_.text = table_controller.jpy

        defaults?.synchronize()
        let gettext = String(describing: defaults!.object(forKey: "progress_on") ?? "")
        if gettext == "" || gettext == "1"{
            progresson.isOn = false
        }else{
            progresson.isOn = false
        }
        
        let gettext2 = String(describing: defaults!.object(forKey: "money_v") ?? "")
        if gettext2 == "" || gettext2 == "0"{
            money_v.isOn = false
            usd_cell.contentView.alpha = 0.5
            jpy_cell.contentView.alpha = 0.5
            //cny_cell.contentView.alpha = 0.5
            usd_cell.isUserInteractionEnabled = false
            jpy_cell.isUserInteractionEnabled = false
            //cny_cell.isUserInteractionEnabled = false
        }else{
            money_v.isOn = true
            usd_cell.contentView.alpha = 1
            jpy_cell.contentView.alpha = 1
            //cny_cell.contentView.alpha = 1
            usd_cell.isUserInteractionEnabled = true
            jpy_cell.isUserInteractionEnabled = true
            //cny_cell.isUserInteractionEnabled = true
            usd_text.text = table_controller.usd_f
            jpy_text.text = table_controller.jpy_f
            //cny_text.text = table_controller.cny_f
        }
    }
    
    func select_money(){
        let dialog = ZAlertView(title: "가격 단위를 선택해주세요.", message: nil, alertType: ZAlertView.AlertType.multipleChoice)
        dialog.addButton("거래소별 단위", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "WHAT"
            self.select_m_texrt.text = "거래소별 단위"
            self.save_kind()
        })
        dialog.addButton("달러(USD)", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "USD"
            self.select_m_texrt.text = "달러(USD)"
            self.save_kind()
        })
        dialog.addButton("엔(JPY)", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            kind_price = "JPY"
            self.select_m_texrt.text = "엔(JPY)"
            self.save_kind()
        })
        dialog.show()
    }
    
    func add_pri(){
        var dialog = SelectionDialog(title: "프리미엄 거래소 선택", closeButtonTitle: "닫기")
        func add_w_item(str:String){
            dialog.addItem(item: str, didTapHandler: { () in
                primium_change = str
                self.pri_change_set.text = primium_change
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
    
    func save_kind() {
        let defaults = UserDefaults(suiteName: "group.jungcode.coin")
        defaults?.set(String(kind_price), forKey: "kind")
        defaults?.synchronize()
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



