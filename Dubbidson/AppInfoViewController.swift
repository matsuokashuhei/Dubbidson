//
//  InfoViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/12/31.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import UIKit
import XCGLogger
import Social
import WebKit
import SafariServices

class AppInfoViewController: UITableViewController {

    let logger = XCGLogger.defaultInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AppInfoViewController {

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            logger.verbose("0")
        case (0, 1):
            logger.verbose("1")
        case (1, 0):
            logger.verbose("2")
        case (1, 1):
            logger.verbose("3")
        default:
            break
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            logger.verbose("0")
            showSharingApp()
        case (0, 1):
            logger.verbose("1")
            showAppStore()
        case (1, 0):
            logger.verbose("2")
            showOpenSourceLicenses()
        case (1, 1):
            logger.verbose("3")
        default:
            break
        }
    }

    func showSharingApp() {
        let text = NSLocalizedString("Dubbidson", comment: "Dubbidson")
        let URL = NSURL(string: "http://itunes.apple.com/app/id1031230674?mt=8")!
        let controller = UIActivityViewController(activityItems: [text, URL], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        /*
        let SNSs = [
            (name: "Twitter", type: SLServiceTypeTwitter),
            (name: "Facebook", type: SLServiceTypeFacebook)
        ]
        let text = NSLocalizedString("Dubbidson", comment: "Dubbidson")
        let URL = NSURL(string: "http://itunes.apple.com/app/id1031230674?mt=8")!
        let shareMenu = UIAlertController(title: nil, message: NSLocalizedString("Share using", comment: "Share using"), preferredStyle: .ActionSheet)
        //for SNS in [(name: "Twitter", type: SLServiceTypeTwitter), (name: "Facebook", type: SLServiceTypeFacebook)] {
        for SNS in SNSs {
            let action = UIAlertAction(title: SNS.name, style: .Default) { (action) in
                if SLComposeViewController.isAvailableForServiceType(SNS.type) {
                    let controller = SLComposeViewController(forServiceType: SNS.type)
                    controller.setInitialText(text)
                    controller.addURL(URL)
                    self.presentViewController(controller, animated: true, completion: nil)
                } else {
                    let localizedString = NSLocalizedString("You haven't registered your %@ account. Please go to Settings > %@ to create one.", comment: "SNS")
                    let message = String(format: localizedString, SNS.name, SNS.name)
                    HUD.sharedInstance.showInfo(message)
                }
            }
            shareMenu.addAction(action)
        }
        shareMenu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel, handler: nil))
        presentViewController(shareMenu, animated: true, completion: nil)
        */
    }

    func showAppStore() {
        let URL = "itms-apps://itunes.apple.com/app/id1031230674"
        UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
    }

    func showOpenSourceLicenses() {
        performSegueWithIdentifier(R.segue.showLicense, sender: nil)
    }

    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case R.segue.showLicense:
                let controller = segue.destinationViewController as! OpenSourceLicensesViewController
            default:
                super.prepareForSegue(segue, sender: sender)
            }
        }
    }
    */
}

class OpenSourceLicensesViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    override func viewDidLoad() {
        guard
            let resource = NSBundle.mainBundle().pathForResource("LICENSES", ofType: "html"),
            let HTML = try? String(contentsOfFile: resource, encoding: NSUTF8StringEncoding)
        else {
            fatalError("LISENCES.html not found.")
        }
        //let webView = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        let webView = WKWebView(frame: CGRectZero, configuration: WKWebViewConfiguration())
        webView.loadHTMLString(HTML, baseURL: nil)
        self.view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: webView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: webView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: webView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: webView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0),
        ])
    }

    override func viewWillAppear(animated: Bool) {
        logger.verbose("")
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
}