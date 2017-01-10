//
//  ViewController.swift
//  EasyMapDemo
//
//  Created by ghysrc on 2017/1/10.
//  Copyright © 2017年 ghysrc. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    private var location:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func startLocating(_ sender: UIButton) {
        Map.getLocation(onSuccess: { (location) in
            self.location = location
            sender.setTitle("\(location.coordinate.latitude), \(location.coordinate.longitude)", for: .normal)
        }) { (error) in
            self.showAlert(title: error.localizedDescription)
        }
    }
    
    @IBAction func reverseGeocoder(_ sender: UIButton) {
        if let l = self.location {
            Map.reverseGeocoder(location: l, onSuccess: { (placeMarks) in
                let mark = placeMarks[0]
                if let province = mark.administrativeArea, let city = mark.locality, let name = mark.name {
                    self.showAlert(title: province + ", " + city + ", " + name)
                }
            }, onFail: { (error) in
                self.showAlert(title: error.localizedDescription)
            })
        } else {
            self.showAlert(title: "Click Locate First")
        }
    }
    @IBAction func poiSearch(_ sender: UIButton) {
        if let l = self.location {
            Map.searchPoi(near: l.coordinate, radius: 1000, keyWords: "hotel", onSuccess: { (items) in
                var names = [String]()
                for item in items {
                    names.append(item.name!)
                }
                self.showActionSheet(title: "POI Result", buttons: names)
            }, onFail: { (error) in
                self.showAlert(title: error.localizedDescription)
            })
        } else {
            self.showAlert(title: "Click Locate First")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

