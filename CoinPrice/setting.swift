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
    
   
    @IBOutlet weak var pri_change_set: UILabel!
    @IBOutlet var tableview: UITableView!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        if (primium_change == ""){
            pri_change_set.text = "선택"
        }else{
            pri_change_set.text = primium_change
        }
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print("section: \(indexPath.section) row: \(indexPath.row)")
        
        
        if indexPath.section == 0 && indexPath.row == 0 {
            add_pri()
        }
        
        
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let dialog = ZAlertView(title: "정보", message: "https://github.com/zelic91/ZAlertView\nhttps://github.com/gpbl/SwiftChart", closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            let dialog = ZAlertView(title: "면책조항", message: "본 개발자는 정보의 정확성을 보장하기 위해 합당한 조치를 취했으나 정확성을 보장하지 않으며, 발생할 수있는 손실이나 손해에 대해 책임을 지지 않습니다.", closeButtonText: "확인", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    
    func add_pri(){
        let dialog = SelectionDialog(title: "프리미엄 거래소 선택", closeButtonTitle: "닫기")
        dialog.addItem(item: "Poloniex", didTapHandler: { () in
            dialog.close()
            primium_change = "Poloniex"
            self.pri_change_set.text = primium_change
        })
        dialog.addItem(item: "BitTrex", didTapHandler: { () in
            dialog.close()
            primium_change = "BitTrex"
            self.pri_change_set.text = primium_change
        })
        dialog.addItem(item: "Bitfinex", didTapHandler: { () in
            dialog.close()
            primium_change = "Bitfinex"
            self.pri_change_set.text = primium_change
        })
        dialog.addItem(item: "Coinone", didTapHandler: { () in
            dialog.close()
            primium_change = "Coinone"
            self.pri_change_set.text = primium_change
        })
        dialog.addItem(item: "Bithumb", didTapHandler: { () in
            dialog.close()
            primium_change = "Bithumb"
            self.pri_change_set.text = primium_change
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
}



