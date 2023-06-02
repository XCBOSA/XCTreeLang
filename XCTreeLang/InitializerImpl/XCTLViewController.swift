//
//  UIViewController.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import UIKit

@objcMembers
public class XCTLViewController: UIViewController, XCTLGenerateProtocol {
    
    public static func initWithXCT(_ arg: [Any]) throws -> NSObject {
        let obj = XCTLViewController()
        for it in arg {
            if let vc = it as? UIViewController {
                obj.addChild(vc)
            } else {
                throw XCTLRuntimeError.generateProtocolArgumentError(needs: "VC...")
            }
        }
        return obj
    }
    
    public override func viewDidLoad() {
        self.view.backgroundColor = UIColor.systemCyan
        super.viewDidLoad()
        for it in self.children {
            self.view.addSubview(it.view)
        }
        for (id, it) in view.subviews.enumerated() {
            it.translatesAutoresizingMaskIntoConstraints = false
            if id == 0 {
                it.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            } else {
                it.heightAnchor.constraint(equalTo: self.view.subviews[id - 1].heightAnchor).isActive = true
            }
            it.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            it.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            if id == view.subviews.count - 1 {
                it.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            }
        }
    }
    
}
