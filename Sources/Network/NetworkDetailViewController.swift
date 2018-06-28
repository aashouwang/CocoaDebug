//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class NetworkDetailViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    lazy var formatter: DateFormatter = DateFormatter()
    
    var httpModel: HttpModel?
    
    lazy var detailModels: [NetworkDetailModel] = [NetworkDetailModel]()
    
    lazy var requestDictionary: [String: Any]? = Dictionary()
    
    var headerCell: NetworkCell?

    var justCancelCallback:(() -> Void)?
    
    static func instanceFromStoryBoard() -> NetworkDetailViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: DotzuX.self))
        return storyboard.instantiateViewController(withIdentifier: "NetworkDetailViewController") as! NetworkDetailViewController
    }
    
    
    //MARK: - tool
    func setupModels()
    {
        guard let requestSerializer = httpModel?.requestSerializer else {return}
        var requestContent: String? = nil
        
        //容错判断,否则为nil时会崩溃
        if httpModel?.requestData == nil {
            httpModel?.requestData = Data.init()
        }
        if httpModel?.responseData == nil {
            httpModel?.responseData = Data.init()
        }
        
        //判断请求参数格式JSON/Form
        if requestSerializer == JSONRequestSerializer {
            //JSON
            requestContent = httpModel?.requestData.dataToPrettyPrintString()
        }
        if requestSerializer == FormRequestSerializer {
            //Form
            requestContent = httpModel?.requestData.dataToString()
        }
        
        if httpModel?.isImage == true {
            //图片:
            //1.主要
            let model_1 = NetworkDetailModel.init(title: "URL", content: "http://DotzuX.com")
            let model_3 = NetworkDetailModel.init(title: "REQUEST", content: requestContent)
            var model_5 = NetworkDetailModel.init(title: "RESPONSE", content: nil)
            let model_6 = NetworkDetailModel.init(title: "ERROR", content: httpModel?.errorLocalizedDescription)
            let model_7 = NetworkDetailModel.init(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription)
            if let responseData = httpModel?.responseData {
                model_5 = NetworkDetailModel.init(title: "RESPONSE", content: nil, UIImage.init(data: responseData))
            }
            //2.次要
            let model_8 = NetworkDetailModel.init(title: "TOTAL TIME", content: httpModel?.totalDuration)
            let model_9 = NetworkDetailModel.init(title: "MIME TYPE", content: httpModel?.mineType)
            var model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: nil)
            if let requestHeaderFields = httpModel?.requestHeaderFields {
                if !requestHeaderFields.isEmpty {
                    model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: requestHeaderFields.description)
                    model_2.requestHeaderFields = requestHeaderFields
                    model_2.content = String(requestHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                }
            }
            var model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: nil)
            if let responseHeaderFields = httpModel?.responseHeaderFields {
                if !responseHeaderFields.isEmpty {
                    model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: responseHeaderFields.description)
                    model_4.responseHeaderFields = responseHeaderFields
                    model_4.content = String(responseHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                }
            }
            //3.
            detailModels.append(model_1)
            detailModels.append(model_2)
            detailModels.append(model_3)
            detailModels.append(model_4)
            detailModels.append(model_5)
            detailModels.append(model_6)
            detailModels.append(model_7)
            detailModels.append(model_8)
            detailModels.append(model_9)
        }
        else{
            //非图片:
            //1.主要
            let model_1 = NetworkDetailModel.init(title: "URL", content: "http://DotzuX.com")
            let model_3 = NetworkDetailModel.init(title: "REQUEST", content: requestContent)
            let model_5 = NetworkDetailModel.init(title: "RESPONSE", content: httpModel?.responseData.dataToPrettyPrintString())
            let model_6 = NetworkDetailModel.init(title: "ERROR", content: httpModel?.errorLocalizedDescription)
            let model_7 = NetworkDetailModel.init(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription)
            //2.次要
            let model_8 = NetworkDetailModel.init(title: "TOTAL TIME", content: httpModel?.totalDuration)
            let model_9 = NetworkDetailModel.init(title: "MIME TYPE", content: httpModel?.mineType)
            var model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: nil)
            if let requestHeaderFields = httpModel?.requestHeaderFields {
                if !requestHeaderFields.isEmpty {
                    model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: requestHeaderFields.description)
                    model_2.requestHeaderFields = requestHeaderFields
                    model_2.content = String(requestHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                }
            }
            var model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: nil)
            if let responseHeaderFields = httpModel?.responseHeaderFields {
                if !responseHeaderFields.isEmpty {
                    model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: responseHeaderFields.description)
                    model_4.responseHeaderFields = responseHeaderFields
                    model_4.content = String(responseHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                }
            }
            //3.
            detailModels.append(model_1)
            detailModels.append(model_2)
            detailModels.append(model_3)
            detailModels.append(model_4)
            detailModels.append(model_5)
            detailModels.append(model_6)
            detailModels.append(model_7)
            detailModels.append(model_8)
            detailModels.append(model_9)
        }
    }
    
    //确定request格式(JSON/Form)
    func detectRequestSerializer() {
        guard let requestData = httpModel?.requestData else {
            httpModel?.requestSerializer = JSONRequestSerializer//默认JSON格式
            return
        }
        
        if let _ = requestData.dataToDictionary() {
            //JSON格式
            httpModel?.requestSerializer = JSONRequestSerializer
        }else{
            //Form格式
            httpModel?.requestSerializer = FormRequestSerializer
        }
    }
    
    
    //email configure
    func configureMailComposer() -> MFMailComposeViewController {
        
        //1.email recipients
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(DotzuXSettings.shared.emailToRecipients)
        mailComposeVC.setCcRecipients(DotzuXSettings.shared.emailCcRecipients)
        
        //2.image
        var isImage: Bool = false
        if let httpModel = httpModel {
            isImage = httpModel.isImage
        }
        
        //3.MessageBody --------- start ---------
        var messageBody: String = ""
        var string: String = ""
        
        for model in detailModels {
            if let title = model.title, let content = model.content {
                if content != "" {
                    string = "\n\n" + "------- " + title + " -------" + "\n" + content
                }
            }
            if !messageBody.contains(string) {
                messageBody.append(string)
            }
            //image
            if isImage == true {
                if let image = model.image {
                    if let imageData = UIImagePNGRepresentation(image) {
                        mailComposeVC.addAttachmentData(imageData, mimeType: "image/png", fileName: "image")
                    }
                }
            }
        }
        
        //4.url
        var url: String = ""
        if let httpModel = httpModel {
            url = httpModel.url.absoluteString
        }
        
        //5.method
        var method: String = ""
        if let httpModel = httpModel {
            method = "[" + httpModel.method + "]"
        }
        
        //6.time
        var time: String = ""
        if let httpModel = httpModel {
            if let startTime = httpModel.startTime {
                if (startTime as NSString).doubleValue == 0 {
                    time = formatter.string(from: Date())
                }else{
                    time = formatter.string(from: NSDate(timeIntervalSince1970: (startTime as NSString).doubleValue) as Date)
                }
            }
        }
        
        //7.statusCode
        var statusCode: String = ""
        if let httpModel = httpModel {
            statusCode = httpModel.statusCode
            if statusCode == "0" { //"0" means network unavailable
                statusCode = "❌"
            }
        }
        
        //8.MessageBody --------- end ---------
        var subString = method + " " + time + " " + "(" + statusCode + ")"
        if subString.contains("❌") {
            subString = subString.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        }
        
        messageBody = messageBody.replacingOccurrences(of: "http://DotzuX.com", with: url)
        messageBody = subString + messageBody
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        
        //9.subject
        mailComposeVC.setSubject(url)

        return mailComposeVC
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        //确定request格式(JSON/Form)
        detectRequestSerializer()
            
        setupModels()
        
        if var lastModel = detailModels.last {
            lastModel.isLast = true
            detailModels.removeLast()
            detailModels.append(lastModel)
        }
        
        //使用单独的xib-cell文件, 必须注册, 否则崩溃
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NetworkCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "NetworkCell")
        
        //header
        headerCell = bundle.loadNibNamed(String(describing: NetworkCell.self), owner: nil, options: nil)?.first as? NetworkCell
        headerCell?.httpModel = httpModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(motionShake_notification), name: NSNotification.Name("motionShake_DotzuX"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)

        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }
    }
    
    //MARK: - target action
    @IBAction func close(_ sender: UIBarButtonItem) {
        (self.navigationController as! DotzuXNavigationController).exit()
    }
    
    //MARK: - notification
    @objc func motionShake_notification() {
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
            DotzuXSettings.shared.responseShakeNetworkDetail = false
        }
    }
    
    
    //MARK: - override
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(selectAll(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func selectAll(_ sender: Any?) {
        headerCell?.requestUrlTextView.selectAll(sender)
    }
}

//MARK: - UITableViewDataSource
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
//                as! NetworkCell
//            cell.httpModel = httpModel
//            return cell
//        }
        
        //------------------------------------------------------------------------------
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkDetailCell", for: indexPath)
            as! NetworkDetailCell
        cell.detailModel = detailModels[indexPath.row]
        
        //1.点击了标题view
//        cell.tapTitleViewCallback = { [weak self] detailModel in
//            if let index = self?.detailModels.index(where: { (model_) -> Bool in
//                return model_.title == detailModel?.title
//            }) {
//                if var model = self?.detailModels[index] {
//                    if model.blankContent == "..." {
//                        model.blankContent = nil
//                    }else{
//                        model.blankContent = "..."
//                    }
//                    self?.detailModels.remove(at: index)
//                    self?.detailModels.insert(model, at: index)
//                }
//            }
//            self?.tableView.reloadData()
//        }
        
        //2.点击了编辑view
        cell.tapEditViewCallback = { [weak self] detailModel in
            let vc = JsonViewController.instanceFromStoryBoard()
            vc.detailModel = detailModel
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let detailModel = detailModels[indexPath.row]
        
        if detailModel.blankContent == "..." {
            if detailModel.isLast == true {
                return 50.5
            }
            return 50
        }
        
        if indexPath.row == 0 {
            return 0
        }
        
        if detailModel.image == nil {
            if let content = detailModel.content {
                if content == "" {
                    return 0
                }
                //计算NSString高度
                let height = content.dotzuX_height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 30))
                return height + 70
            }
            return 0
        }
        
        return UIScreen.main.bounds.size.width + 50
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerCell?.contentView
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let serverURL = DotzuXSettings.shared.serverURL else {return 0}
        
        var height: CGFloat = 0.0
        if let cString = self.httpModel?.url.absoluteString.cString(using: String.Encoding.utf8) {
            if let content_ = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) {
                
                if self.httpModel?.url.absoluteString.contains(serverURL) == true {
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.dotzuX_height(with: UIFont.systemFont(ofSize: 13, weight: .heavy), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.dotzuX_height(with: UIFont.boldSystemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }else{
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.dotzuX_height(with: UIFont.systemFont(ofSize: 13, weight: .regular), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.dotzuX_height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }
                return height + 57
            }
        }
        return 0
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension NetworkDetailViewController {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) {
            if error != nil {
                let alert = UIAlertController.init(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
                    DotzuXSettings.shared.responseShakeNetworkDetail = true
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }else{
                DotzuXSettings.shared.responseShakeNetworkDetail = true
            }
        }
    }
}
