//
//  Created by ghysrc on 2016/12/30.
//  Copyright © 2016年 ghysrc. All rights reserved.
//

typealias BMapLocateSuccessHandler = ((CLLocation) -> Void)
typealias BMapLocateFailHandler = ((Error) -> Void)
typealias BMapReGeocoderSuccessHandler = ((BMKReverseGeoCodeResult) -> Void)
typealias BMapGeocoderSuccessHandler = ((BMKGeoCodeResult) -> Void)
typealias BMapSearchFailHandler = ((BMKSearchErrorCode) -> Void)
typealias BMapPoiSearchSuccessHandler = ((BMKPoiResult) -> Void)
typealias BMapSuggestionSearchSuccessHandler = ((BMKSuggestionResult) -> Void)

let BMap:BMapManager = BMapManager()

class BMapManager: NSObject, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, BMKSuggestionSearchDelegate {
    
    private let locationService: BMKLocationService
    private lazy var searchService = BMKGeoCodeSearch()
    private lazy var poiSearch = BMKPoiSearch()
    private lazy var suggestionSearch = BMKSuggestionSearch()
    
    private var locateSuccess: BMapLocateSuccessHandler?
    private var locateFail: BMapLocateFailHandler?
    private var regeocoderSuccess: BMapReGeocoderSuccessHandler?
    private var geoCoderSuccess: BMapGeocoderSuccessHandler?
    private var poiSearchSuccess: BMapPoiSearchSuccessHandler?
    private var suggestionSearchSuccess: BMapSuggestionSearchSuccessHandler?
    private var searchFail: BMapSearchFailHandler?
    
    override init() {
        self.locationService = BMKLocationService()
        super.init()
        self.locationService.delegate = self
    }
    
    func requestAuthorization(whenInUse:Bool = true) {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied {
            print("Location Service disabled or authorization denied.")
            return
        }
        let clManager = CLLocationManager()
        if whenInUse {
            clManager.requestWhenInUseAuthorization()
        } else {
            clManager.requestAlwaysAuthorization()
        }
    }
    
    /**
     
     * Start continuouts locating
     
     * Default desiredAccuracy is kCLLocationAccuracyHundredMeters
     
     * Default distanceFilter is 200 meters
     
     */
    func getLocation(withAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters, distanceFilter: CLLocationDistance = 200, onSuccess: @escaping BMapLocateSuccessHandler, onFail: @escaping BMapLocateFailHandler) {
        requestAuthorization()
        locateSuccess = onSuccess
        locateFail = onFail
        locationService.desiredAccuracy = withAccuracy
        locationService.distanceFilter = distanceFilter
        locationService.startUserLocationService()
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        locateSuccess?(userLocation.location)
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        locateFail?(error)
    }
    
    /// coordinate to address
    func reverseGeocoder(coordinate:CLLocationCoordinate2D, onSuccess:@escaping BMapReGeocoderSuccessHandler, onFail: @escaping BMapSearchFailHandler) {
        regeocoderSuccess = onSuccess
        searchFail = onFail
        searchService.delegate = self
        let regeo = BMKReverseGeoCodeOption()
        regeo.reverseGeoPoint = coordinate
        searchService.reverseGeoCode(regeo)
    }
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            regeocoderSuccess?(result)
        } else {
            searchFail?(error)
        }
    }
    
    /// address to coordinate, city can be empty
    func geocoder(address:String, city:String, onSuccess: @escaping BMapGeocoderSuccessHandler, onFail: @escaping BMapSearchFailHandler) {
        geoCoderSuccess = onSuccess
        searchFail = onFail
        searchService.delegate = self
        let geo = BMKGeoCodeSearchOption()
        geo.city = city
        geo.address = address
        searchService.geoCode(geo)
    }
    
    func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            geoCoderSuccess?(result)
        } else {
            searchFail?(error)
        }
    }
    
    /**
     
     * Search nearby pois
     
     * Note: The keyword can NOT be nil or empty, it's required by SDK. If you want to get all kinds of pois, consider use reverseGeocoder instead.
     
     */
    func searchPoi(near location:CLLocationCoordinate2D, radius:Int32, keyword:String, pageIndex:Int32 = 1, pageCapacity:Int32 = 20, onSuccess: @escaping BMapPoiSearchSuccessHandler, onFail: @escaping BMapSearchFailHandler) {
        let option = BMKNearbySearchOption()
        option.location = location
        option.radius = radius
        option.keyword = keyword
        option.pageIndex = pageIndex
        option.pageCapacity = pageCapacity
        poiSearchSuccess = onSuccess
        searchFail = onFail
        poiSearch.delegate = self
        poiSearch.poiSearchNear(by: option)
    }
    
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            poiSearchSuccess?(poiResult)
        } else {
            searchFail?(errorCode)
        }
    }
    
    /// Get suggestions by keyword
    func searchInputTips(keyword:String, city:String?, onSuccess: @escaping BMapSuggestionSearchSuccessHandler, onFail: @escaping BMapSearchFailHandler) {
        let option = BMKSuggestionSearchOption()
        option.cityname = city
        option.keyword = keyword
        suggestionSearchSuccess = onSuccess
        searchFail = onFail
        suggestionSearch.delegate = self
        suggestionSearch.suggestionSearch(option)
    }
    
    func onGetSuggestionResult(_ searcher: BMKSuggestionSearch!, result: BMKSuggestionResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            suggestionSearchSuccess?(result)
        } else {
            searchFail?(error)
        }
    }
    
}
