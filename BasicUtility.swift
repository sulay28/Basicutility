

import UIKit
import SystemConfiguration
class ShowToast: NSObject {
    static var lastToastLabelReference:UILabel?
    static var initialYPos:CGFloat = 0
    class func show(toatMessage:String)
    {
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window
        {
            ShowHud.hide()
            if lastToastLabelReference != nil
            {
                let prevMessage = lastToastLabelReference!.text?.replacingOccurrences(of: " ", with: "").lowercased()
                let currentMessage = toatMessage.replacingOccurrences(of: " ", with: "").lowercased()
                if prevMessage == currentMessage
                {
                    return
                }
            }
            
            let cornerRadious:CGFloat = 12
            let toastContainerView:UIView={
                let view = UIView()
                view.layer.cornerRadius = cornerRadious
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor.redThemeColor()
                view.alpha = 0.8
                return view
            }()
            let labelForMessage:UILabel={
                let label = UILabel()
                label.layer.cornerRadius = cornerRadious
                label.layer.masksToBounds = true
                label.textAlignment = .center
                label.numberOfLines = 0
                label.adjustsFontSizeToFitWidth = true
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = toatMessage
                label.textColor = .white
                label.backgroundColor = UIColor.init(white: 0, alpha: 0)
                return label
            }()
            
            keyWindow.addSubview(toastContainerView)
            
            let fontType = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 14 : 12)
            labelForMessage.font = fontType
            
            let sizeOfMessage = NSString(string: toatMessage).boundingRect(with: CGSize(width: keyWindow.frame.width, height: keyWindow.frame.height), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:fontType], context: nil)
            
            let topAnchor = toastContainerView.bottomAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0)
            keyWindow.addConstraint(topAnchor)
            
            toastContainerView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor, constant: 0).isActive = true
            
            var extraHeight:CGFloat = 0
            if (keyWindow.frame.size.width) < (sizeOfMessage.width+20)
            {
                extraHeight = (sizeOfMessage.width+20) - (keyWindow.frame.size.width)
                toastContainerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 5).isActive = true
                toastContainerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: -5).isActive = true
            }
            else
            {
                toastContainerView.widthAnchor.constraint(equalToConstant: sizeOfMessage.width+20).isActive = true
            }
            let totolHeight:CGFloat = sizeOfMessage.height+25+extraHeight
            toastContainerView.heightAnchor.constraint(equalToConstant:totolHeight).isActive = true
            toastContainerView.addSubview(labelForMessage)
            lastToastLabelReference = labelForMessage
            labelForMessage.topAnchor.constraint(equalTo: toastContainerView.topAnchor, constant: 0).isActive = true
            labelForMessage.bottomAnchor.constraint(equalTo: toastContainerView.bottomAnchor, constant: 0).isActive = true
            labelForMessage.leftAnchor.constraint(equalTo: toastContainerView.leftAnchor, constant: 5).isActive = true
            labelForMessage.rightAnchor.constraint(equalTo: toastContainerView.rightAnchor, constant: -5).isActive = true
            keyWindow.layoutIfNeeded()
            
            let padding:CGFloat = initialYPos == 0 ? (DeviceType.isIpad() ? 140 : 100) : 10 // starting position
            initialYPos += padding+totolHeight
            topAnchor.constant = initialYPos
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                keyWindow.layoutIfNeeded()
            }, completion: { (bool) in
                
                topAnchor.constant = 0
                UIView.animate(withDuration: 0.4, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                    keyWindow.layoutIfNeeded()
                }, completion: { (bool) in
                    if let lastToastShown = lastToastLabelReference,labelForMessage == lastToastShown
                    {
                        lastToastLabelReference = nil
                    }
                    initialYPos -= (padding+totolHeight)
                    toastContainerView.removeFromSuperview()
                })
            })
        }
    }
}
class ShowHud:NSObject
{
    static let disablerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        return view
    }()
    
    static let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
      //  view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.8)
        return view
    }()
    static var loadingIndicator:UIActivityIndicatorView={
        let loading = UIActivityIndicatorView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.activityIndicatorViewStyle = .whiteLarge
        loading.backgroundColor = .clear
        loading.layer.cornerRadius = 16
        loading.layer.masksToBounds = true
        return loading
    }()
    static let loadingMsgLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please wait..."
        label.textAlignment = .center
        let fontType = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
        label.font = fontType
        label.textColor = .white
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    class func show(loadingMessage:String="Please wait...")
    {
        
        UIApplication.shared.resignFirstResponder()
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window
        {
            if !ShowHud.loadingIndicator.isAnimating
            {
                loadingMsgLabel.text = loadingMessage
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                keyWindow.addSubview(disablerView)
                disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
                disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
                disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
                disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
                ShowHud.loadingIndicator.startAnimating()
                
                disablerView.addSubview(containerView)
                
                containerView.centerXAnchor.constraint(equalTo: disablerView.centerXAnchor).isActive = true
                containerView.centerYAnchor.constraint(equalTo: disablerView.centerYAnchor).isActive = true
                let squareSize:CGFloat = DeviceType.isIpad() ? 160 : 140
                containerView.widthAnchor.constraint(equalToConstant: squareSize).isActive = true
                containerView.heightAnchor.constraint(equalToConstant: squareSize).isActive = true
                
                
                containerView.addSubview(loadingMsgLabel)
                loadingMsgLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor ,constant:-10).isActive = true
                loadingMsgLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor,constant:-6).isActive = true
                loadingMsgLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant:6).isActive = true
                
                containerView.addSubview(loadingIndicator)
                loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            }
            else
            {
                loadingMsgLabel.text = loadingMessage
            }
        }
        
    }
    class func hide(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ShowHud.loadingIndicator.stopAnimating()
        ShowHud.disablerView.removeFromSuperview()
    }
}
protocol CustomPickerViewDelegate:class{
    
    func didTappedDoneButton(selectedValue:String,id:String?,index:Int)
    func didSelectValueAtIndexPath(selectedValue:String,id:String?,index:Int)
    func didTappedCancelButton(selectedValue:String,id:String?,index:Int)
}
class ShowPickerView: UIPickerView,UIPickerViewDelegate{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var pickerViewObj = ShowPickerView()
    var delegation:CustomPickerViewDelegate?
    lazy var pickerViewFontColor = UIColor.gray
    var yPosConstraint:NSLayoutConstraint?
    lazy var topActionBar:CGFloat = (DeviceType.isIpad() ? 50 : 40);
    lazy var totalHeight:CGFloat = (DeviceType.isIpad() ? 200 : 130)+self.topActionBar;
    var keys:[String]?
    var ids:[String]?
    let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        return view
    }()
    
    let actionView:UIView={
        let view = UIView()
        view.backgroundColor = UIColor.redThemeColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var cancelButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textColor = pickerViewObj.pickerViewFontColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 20 : 18)
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "cancel"), for:.normal)
        button.addTarget(self, action: #selector(self.cancelButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var doneButton:UIButton={
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textColor = pickerViewObj.pickerViewFontColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 20 : 18)
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "done"), for:.normal)
        button.addTarget(self, action: #selector(self.doneButtonAction), for: .touchUpInside)
        return button
    }()
    
    var prevouseSelectedIndex:Int?
    
    class func showPickerView(values:[String],ids:[String]?,selectedValue:String = "")
    {
        //adding picker view
        if let keyWindow = UIApplication.shared.keyWindow
        {
            pickerViewObj =  ShowPickerView()
            
            keyWindow.addSubview(pickerViewObj.containerView)
            pickerViewObj.containerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: 0).isActive = true
            pickerViewObj.containerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 0).isActive = true
            pickerViewObj.containerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
            pickerViewObj.containerView.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
            
            pickerViewObj.keys = values
            pickerViewObj.ids = ids
            for (index,value) in pickerViewObj.keys!.enumerated()
            {
                if value.lowercased().replacingOccurrences(of: " ", with: "") == selectedValue.lowercased().replacingOccurrences(of: " ", with: "")
                {
                    pickerViewObj.selectRow(index, inComponent: 0, animated: true)
                    pickerViewObj.prevouseSelectedIndex = index
                    break
                }
            }
            
            pickerViewObj.containerView.addSubview(pickerViewObj)
            
            
            
            pickerViewObj.yPosConstraint = pickerViewObj.bottomAnchor.constraint(equalTo: pickerViewObj.containerView.bottomAnchor, constant:pickerViewObj.totalHeight)
            pickerViewObj.containerView.addConstraint(pickerViewObj.yPosConstraint!)
            pickerViewObj.heightAnchor.constraint(equalToConstant: pickerViewObj.totalHeight).isActive = true
           
            pickerViewObj.rightAnchor.constraint(equalTo: pickerViewObj.containerView.rightAnchor, constant: 0).isActive = true
            pickerViewObj.leftAnchor.constraint(equalTo: pickerViewObj.containerView.leftAnchor, constant: 0).isActive = true
            
            //adding top action sheet
            pickerViewObj.containerView.addSubview(pickerViewObj.actionView)
            pickerViewObj.actionView.rightAnchor.constraint(equalTo: pickerViewObj.rightAnchor, constant: 0).isActive = true
            pickerViewObj.actionView.heightAnchor.constraint(equalToConstant: pickerViewObj.topActionBar).isActive = true
            pickerViewObj.actionView.leftAnchor.constraint(equalTo: pickerViewObj.leftAnchor, constant: 0).isActive = true
            pickerViewObj.actionView.bottomAnchor.constraint(equalTo: pickerViewObj.topAnchor).isActive = true
            
            pickerViewObj.actionView.addSubview(pickerViewObj.cancelButton)
            pickerViewObj.actionView.addSubview(pickerViewObj.doneButton)
            pickerViewObj.cancelButton.topAnchor.constraint(equalTo: pickerViewObj.actionView.topAnchor).isActive = true
            pickerViewObj.cancelButton.bottomAnchor.constraint(equalTo: pickerViewObj.actionView.bottomAnchor).isActive = true
            pickerViewObj.cancelButton.leftAnchor.constraint(equalTo: pickerViewObj.actionView.leftAnchor).isActive = true
            pickerViewObj.cancelButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            pickerViewObj.doneButton.topAnchor.constraint(equalTo: pickerViewObj.actionView.topAnchor).isActive = true
            pickerViewObj.doneButton.bottomAnchor.constraint(equalTo: pickerViewObj.actionView.bottomAnchor).isActive = true
            pickerViewObj.doneButton.rightAnchor.constraint(equalTo: pickerViewObj.actionView.rightAnchor).isActive = true
            pickerViewObj.doneButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            pickerViewObj.containerView.layoutIfNeeded()
            pickerViewObj.yPosConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                pickerViewObj.containerView.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
    func doneButtonAction()
    {
        self.hidePickerView()
        
        var idForSelectedValu:String?
        
        if let ids = ShowPickerView.pickerViewObj.ids{
            if ids.count > self.selectedRow(inComponent: 0){
                idForSelectedValu = ids[self.selectedRow(inComponent: 0)]
            }
        }
        
        ShowPickerView.pickerViewObj.delegation?.didTappedDoneButton(selectedValue: ShowPickerView.pickerViewObj.keys![self.selectedRow(inComponent: 0)], id:idForSelectedValu, index: self.selectedRow(inComponent: 0))
    }
    func cancelButtonAction()
    {
        self.hidePickerView()
        var idForSelectedValu:String?
        
        if let ids = ShowPickerView.pickerViewObj.ids{
            if ids.count > self.selectedRow(inComponent: 0){
                idForSelectedValu = ids[self.selectedRow(inComponent: 0)]
            }
        }
        if let index = ShowPickerView.pickerViewObj.prevouseSelectedIndex
        {
            ShowPickerView.pickerViewObj.delegation?.didTappedCancelButton(selectedValue:ShowPickerView.pickerViewObj.keys![index], id: idForSelectedValu, index:index)
        }
        
    }
    func hidePickerView()
        
    {
        
        ShowPickerView.pickerViewObj.yPosConstraint?.constant = (ShowPickerView.pickerViewObj.totalHeight+ShowPickerView.pickerViewObj.topActionBar)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseIn, animations: {
            ShowPickerView.pickerViewObj.containerView.layoutIfNeeded()
        }, completion: { (Bool) in
            ShowPickerView.pickerViewObj.actionView.removeFromSuperview()
            ShowPickerView.pickerViewObj.removeFromSuperview()
            ShowPickerView.pickerViewObj.containerView.removeFromSuperview()
        })
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = ShowPickerView.pickerViewObj.keys?.count
        {
            return count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ShowPickerView.pickerViewObj.keys![row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var idForSelectedValu:String?
        
        if let ids = ShowPickerView.pickerViewObj.ids{
            if ids.count > self.selectedRow(inComponent: 0){
                idForSelectedValu = ids[self.selectedRow(inComponent: 0)]
            }
        }
        
        ShowPickerView.pickerViewObj.delegation?.didSelectValueAtIndexPath(selectedValue: ShowPickerView.pickerViewObj.keys![row], id: idForSelectedValu, index: row)
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attributedString = NSAttributedString(string: ShowPickerView.pickerViewObj.keys![row], attributes: [NSForegroundColorAttributeName : pickerView.selectedRow(inComponent: 0) == row ? UIColor.black : ShowPickerView.pickerViewObj.pickerViewFontColor])
        return attributedString
    }
}


protocol CustomDatePickerDeledate:class{
    
    func didTappedDoneButton(selectedDate:Any,id:String?)
}

class DatePickerView{
    static var dateId:String?
    static let datePicker:UIDatePicker={
        let dpv = UIDatePicker()
        dpv.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        dpv.translatesAutoresizingMaskIntoConstraints = false
        return dpv
    }()
    static var delegate:CustomDatePickerDeledate?
    static var yPosConstraint:NSLayoutConstraint?
    static var topActionHeight:CGFloat = (DeviceType.isIpad() ? 50 : 40);
    static var totalHeight:CGFloat = (DeviceType.isIpad() ? 150 : 130)+topActionHeight
    static let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        return view
    }()
    
    static let actionView:UIView={
        let view = UIView()
        view.backgroundColor = UIColor.redThemeColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    static let cancelButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textColor = ShowPickerView.pickerViewObj.pickerViewFontColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 20 : 18)
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "cancel"), for:.normal)
        button.addTarget(DatePickerView.self, action: #selector(DatePickerView.cancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    static let doneButton:UIButton={
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textColor = ShowPickerView.pickerViewObj.pickerViewFontColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 20 : 18)
        button.backgroundColor = .clear
        button.setTitle(Vocabulary.getWordFromKey(key: "done"), for:.normal)
        button.addTarget(DatePickerView.self, action: #selector(DatePickerView.doneButtonClicked), for: .touchUpInside)
        return button
    }()
    
    static func show(mode:UIDatePickerMode = .date,id:String?){
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window  {
            
            dateId = id
            datePicker.datePickerMode = mode
            if mode == .countDownTimer {
                //datePicker.countDownDuration = 0
                datePicker.minuteInterval = 15
            }
            keyWindow.addSubview(containerView)
            containerView.fillOnSupperView()
           
            containerView.addSubview(datePicker)
            
            containerView.addSubview(actionView)
            actionView.rightAnchor.constraint(equalTo: datePicker.rightAnchor, constant: 0).isActive = true
            actionView.heightAnchor.constraint(equalToConstant: topActionHeight).isActive = true
            actionView.leftAnchor.constraint(equalTo: datePicker.leftAnchor, constant: 0).isActive = true
            actionView.bottomAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
            
            actionView.addSubview(cancelButton)
            actionView.addSubview(doneButton)
            cancelButton.topAnchor.constraint(equalTo: actionView.topAnchor).isActive = true
            cancelButton.bottomAnchor.constraint(equalTo: actionView.bottomAnchor).isActive = true
            cancelButton.leftAnchor.constraint(equalTo: actionView.leftAnchor).isActive = true
            cancelButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            doneButton.topAnchor.constraint(equalTo: actionView.topAnchor).isActive = true
            doneButton.bottomAnchor.constraint(equalTo: actionView.bottomAnchor).isActive = true
            doneButton.rightAnchor.constraint(equalTo: actionView.rightAnchor).isActive = true
            doneButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            if DeviceType.isIpad(){
                datePicker.centerOnSuperView()
                datePicker.setHieghtOrWidth(height: 200, width: 400)
                containerView.backgroundColor = UIColor.init(white: 0.5, alpha: 0.2)
            }else{
               
                
                datePicker.anchors(left: containerView.leftAnchor, right: containerView.rightAnchor, top: nil, bottom: nil)
                yPosConstraint = datePicker.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
                containerView.addConstraint(yPosConstraint!)
                
                //adding top action sheet
                
                keyWindow.layoutIfNeeded()
                
                yPosConstraint?.constant = -totalHeight
                
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                    keyWindow.layoutIfNeeded()
                }, completion: nil)
            }
        }
        
    }
    
    
    @objc static func doneButtonClicked(){
        
        let dateMode = datePicker.datePickerMode
        let value:Any = dateMode == .countDownTimer ? datePicker.countDownDuration : datePicker.date
        delegate?.didTappedDoneButton(selectedDate: value, id: dateId)
        DatePickerView.hideDatePicker()
    }
    
    @objc static func hideDatePicker(){
        
        func remove(){
            containerView.removeFromSuperview()
            datePicker.removeFromSuperview()
            actionView.removeFromSuperview()
            doneButton.removeFromSuperview()
            cancelButton.removeFromSuperview()
            delegate = nil
        }
        
        if DeviceType.isIpad(){
            remove()
            return
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            yPosConstraint?.constant = totalHeight
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                keyWindow.layoutIfNeeded()
            }, completion:{ (Bool) in
                 remove()
            })
            
        }
    }
    @objc static func cancelButtonClicked(){
         DatePickerView.hideDatePicker()
    }
}


class DeviceType{
    class func isIpad()->Bool
    {
        return UIDevice.current.userInterfaceIdiom == .pad ? true : false
    }
    class func isIphone5sAndBelow()->Bool{
        if UIScreen.main.bounds.height < 570 {
            return true
        }
        
        return false
    }
    
    class func isIphone4sOrIpad()->Bool{
        if UIScreen.main.bounds.height < 481 || UIDevice.current.model.hasPrefix("iPad") {
            return true
        }
        
        return false
    }
}
class Reachability {
    
    class func isAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
class ShowAlertView{
    class func show(titleMessage:String="Success",desciptionMessage:String="Successfully completed")
    {
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController
        {
            let alert = UIAlertController.init(title: titleMessage, message: desciptionMessage, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
}


extension UIView{
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func anchors(left:NSLayoutXAxisAnchor?,right:NSLayoutXAxisAnchor?,top:NSLayoutYAxisAnchor?,bottom:NSLayoutYAxisAnchor?,leftConstant:CGFloat = 0,rightConstant:CGFloat = 0,topConstant:CGFloat = 0,bottomCosntant:CGFloat = 0){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let leftAnchor = left{
            self.leftAnchor.constraint(equalTo: leftAnchor, constant: leftConstant).isActive = true
        }
        
        if let rightAnchor = right{
            self.rightAnchor.constraint(equalTo: rightAnchor, constant: rightConstant).isActive = true
        }
        
        if let topAnchor = top{
            self.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).isActive = true
        }
        
        if let bottomAnchor = bottom{
            self.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomCosntant).isActive = true
        }
    }
    
    
    func fillOnSupperView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let subperView = self.superview{
            self.leftAnchor.constraint(equalTo: subperView.leftAnchor, constant: 0).isActive = true
            self.rightAnchor.constraint(equalTo: subperView.rightAnchor, constant: 0).isActive = true
            self.topAnchor.constraint(equalTo: subperView.topAnchor, constant: 0).isActive = true
            self.bottomAnchor.constraint(equalTo: subperView.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    func centerOnSuperView(constantX:CGFloat = 0 , constantY:CGFloat = 0 ){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let subperView = self.superview{
            self.centerXAnchor.constraint(equalTo: subperView.centerXAnchor, constant: constantX).isActive = true
            self.centerYAnchor.constraint(equalTo: subperView.centerYAnchor, constant: constantY).isActive = true
        }
    }
    
    
    
    func setHieghtOrWidth(height:CGFloat?,width:CGFloat?){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let heightConst = height{
            self.heightAnchor.constraint(equalToConstant: heightConst).isActive = true
        }
        if let widthAnchor = width{
            self.widthAnchor.constraint(equalToConstant: widthAnchor).isActive = true
        }
    }
    
    
    func centerOnYOrX(x:Bool?,y:Bool?,xConst:CGFloat=0,yConst:CGFloat=0){
        self.translatesAutoresizingMaskIntoConstraints = false
        if x != nil && y != nil{
            
            self.centerOnSuperView(constantX: xConst , constantY: yConst)
        }else if x != nil{
            self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor, constant: xConst ).isActive = true
        }else if y != nil{
            self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor, constant: yConst).isActive = true
        }
        
        
    
    }
    
    func addSubviews(views:[UIView]){
        for view in views{
            self.addSubview(view)
        }
    }
}
extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat,a:CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: a)
    }
}

extension String{
    
    func sqlFriendly()->String{
       return self.replacingOccurrences(of: "'", with: "")
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first.uppercased() + other.lowercased()
    }
    
    func removeWhiteSpaces()->String
    {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func getAttributedString(questring:String) -> NSMutableAttributedString {
     
        var attributedString = NSMutableAttributedString()
        
        let range = NSRange(location:0,length:1)
        
        attributedString = NSMutableAttributedString(string: questring, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 45, weight: 0.1)])
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: range)
        
        return attributedString
    }
    
    func objectToJson(object:Any){
        
        do{
            let parameterData = try JSONSerialization.data(withJSONObject:object, options:.prettyPrinted)
            print(String(data: parameterData, encoding: .utf8)!)
            
        }catch{
        }
        
    }
}

extension TimeInterval {
    var durationText:String {
        let totalSeconds = self
        let hours:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
        
    }
}

extension Dictionary
{
    func updatedValue(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var result = self
        result[key] = value
        return result
    }
    
    var nullsRemoved: [Key: Value] {
        let tup = filter { !($0.1 is NSNull) }
        return tup.reduce([Key: Value]()) { $0.0.updatedValue($0.1.value, forKey: $0.1.key) }
    }
}

class BasicComponent:NSObject{
    static func getTextfield()->UITextField{
    
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .roundedRect
    
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 2))
        
        return tf
    }
}
















