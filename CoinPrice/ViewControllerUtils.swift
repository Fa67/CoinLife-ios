import Foundation
import UIKit

class ViewControllerUtils {
    
    static var container: UIView = UIView()
    static var loadingView: UIView = UIView()
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
     Show customized activity indicator,
     actually add activity indicator to passing view
     
     @param uiView - add activity indicator to this view
     */
    func showActivityIndicator(uiView: UIView) {
        ViewControllerUtils.container.frame = uiView.frame
        ViewControllerUtils.container.center = uiView.center
        ViewControllerUtils.container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        ViewControllerUtils.loadingView.frame = CGRect(x:0, y:0, width: 80, height: 80)
        ViewControllerUtils.loadingView.center = uiView.center
        ViewControllerUtils.loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        ViewControllerUtils.loadingView.clipsToBounds = true
        ViewControllerUtils.loadingView.layer.cornerRadius = 10
        
        ViewControllerUtils.activityIndicator.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        ViewControllerUtils.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        ViewControllerUtils.activityIndicator.center = CGPoint(x:ViewControllerUtils.loadingView.frame.size.width / 2, y: ViewControllerUtils.loadingView.frame.size.height / 2);
        
        ViewControllerUtils.loadingView.addSubview(ViewControllerUtils.activityIndicator)
        ViewControllerUtils.container.addSubview(ViewControllerUtils.loadingView)
        uiView.addSubview(ViewControllerUtils.container)
        ViewControllerUtils.activityIndicator.startAnimating()
    }
    
    /*
     Hide activity indicator
     Actually remove activity indicator from its super view
     
     @param uiView - remove activity indicator from this view
     */
    func hideActivityIndicator(uiView: UIView) {
        ViewControllerUtils.activityIndicator.stopAnimating()
        ViewControllerUtils.container.removeFromSuperview()
    }
    
    /*
     Define UIColor from hex value
     
     @param rgbValue - hex color value
     @param alpha - transparency level
     */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}

//// In order to show the activity indicator, call the function from your view controller
//// ViewControllerUtils().showActivityIndicator(self.view)
//// In order to hide the activity indicator, call the function from your view controller
//// ViewControllerUtils().hideActivityIndicator(self.view)
