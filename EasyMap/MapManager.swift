//
//  Created by ghysrc on 2016/12/27.
//  Copyright © 2016年 ghysrc. All rights reserved.
//

import MapKit

typealias LocateSuccessHandler = ((CLLocation) -> Void)
typealias MapErrorHandler = ((Error) -> Void)
typealias ReGeocoderSuccessHandler = (([CLPlacemark]) -> Void)
typealias MultipleReGeocoderSuccessHandler = (([Any]) -> Void)
typealias GeocoderSuccessHandler = (([CLPlacemark]) -> Void)
typealias MultipleGeocoderSuccessHandler = (([Any]) -> Void)
typealias SearchPoiSuccessHandler = (([MKMapItem]) -> Void)

let Map:MapManager = MapManager.instance

class MapManager: NSObject, CLLocationManagerDelegate {
    
    static let instance = MapManager()
    
    private let clManager: CLLocationManager
    private let clGeocoder: CLGeocoder
    private var locateSuccess: LocateSuccessHandler?
    private var locateFail: MapErrorHandler?
    
    override init() {
        self.clManager = CLLocationManager()
        self.clGeocoder = CLGeocoder()
        super.init()
        self.clManager.delegate = self
    }
    
    func requestAuthorization(whenInUse:Bool = true) {
        if whenInUse {
            self.clManager.requestWhenInUseAuthorization()
        } else {
            self.clManager.requestAlwaysAuthorization()
        }
    }
    
    func getLocation(withAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters, distanceFilter: CLLocationDistance = 200, onSuccess: @escaping LocateSuccessHandler, onFail: @escaping MapErrorHandler) {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied {
            return
        }
        requestAuthorization()
        self.clManager.distanceFilter = distanceFilter
        self.clManager.desiredAccuracy = withAccuracy
        self.locateSuccess = onSuccess
        self.locateFail = onFail
        self.clManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        self.locateSuccess?(newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locateFail?(error)
    }
    
    func reverseGeocoder(location:CLLocation, onSuccess:@escaping ReGeocoderSuccessHandler, onFail: @escaping MapErrorHandler) {
        self.clGeocoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let marks = placeMarks {
                onSuccess(marks)
            } else {
                onFail(error!)
            }
        }
    }
    
    func reverseGeocoder(coordinate:CLLocationCoordinate2D, onSuccess:@escaping ReGeocoderSuccessHandler, onFail: @escaping MapErrorHandler) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.clGeocoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let marks = placeMarks {
                onSuccess(marks)
            } else {
                onFail(error!)
            }
        }
    }
    
    func reverseGeocoder(coordinates:[CLLocationCoordinate2D], onFinished: @escaping MultipleReGeocoderSuccessHandler) {
        var resultMarks = [Any]()
        let signal = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .default).async {
            for coordinate in coordinates {
                self.reverseGeocoder(coordinate: coordinate, onSuccess: { (marks) in
                    resultMarks.append(marks)
                    signal.signal()
                }, onFail: { (error) in
                    resultMarks.append(error)
                    signal.signal()
                })
                signal.wait()
            }
            onFinished(resultMarks)
        }
    }
    
    func geocoder(address:String, region:CLRegion? = nil, onSuccess: @escaping GeocoderSuccessHandler, onFail: @escaping MapErrorHandler) {
        self.clGeocoder.geocodeAddressString(address, in: region) { (placeMarks, error) in
            if let marks = placeMarks {
                onSuccess(marks)
            } else {
                onFail(error!)
            }
        }
    }
    
    func geocoder(addresses:[String], onFinished: @escaping MultipleGeocoderSuccessHandler) {
        var resultMarks = [Any]()
        let signal = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .default).async {
            for address in addresses {
                self.geocoder(address: address, onSuccess: { (marks) in
                    resultMarks.append(marks)
                    signal.signal()
                }, onFail: { (error) in
                    resultMarks.append(error)
                    signal.signal()
                })
                signal.wait()
            }
            onFinished(resultMarks)
        }
    }
    
    func searchPoi(near coordinate:CLLocationCoordinate2D, radius:CLLocationDistance, keyWords:String, onSuccess:@escaping SearchPoiSuccessHandler, onFail: @escaping MapErrorHandler) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        let request = MKLocalSearchRequest()
        request.region = region
        request.naturalLanguageQuery = keyWords
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let items = response?.mapItems {
                onSuccess(items)
            } else {
                onFail(error!)
            }
        }
    }
    
    /// Distance between two coordinates
    func distanceBetween(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D ) -> CLLocationDistance {
        let point1 = MKMapPointForCoordinate(coordinate1)
        let point2 = MKMapPointForCoordinate(coordinate2)
        return MKMetersBetweenMapPoints(point1, point2)
    }
    
}
