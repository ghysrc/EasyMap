//
//  Extensions.swift
//  EasyMapDemo
//
//  Created by ghysrc on 2017/1/10.
//  Copyright © 2017年 ghysrc. All rights reserved.
//


extension UIViewController {
    
    func showAlert(title:String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(title:String, buttons:[String]) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for btn in buttons {
            let action = UIAlertAction(title: btn, style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
}
