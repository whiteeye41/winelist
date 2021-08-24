//
//  ViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/17.
//  Copyright © 2020 cosima. All rights reserved.
//
import Foundation
import UIKit
import MapKit
import CoreLocation
import LocalAuthentication
import FirebaseAnalytics


public class FirstCell:UITableViewCell{
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var imageTop: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class FirstViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,MKMapViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BarList" , for: indexPath) as! FirstCell

        cell.title.text = data[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.imageTop.image = UIImage(systemName: "line.horizontal.3")
        case 1:
            cell.imageTop.image = UIImage(systemName: "calendar")
        case 2:
            cell.imageTop.image = UIImage(systemName: "list.number.rtl")
        case 3:
            cell.imageTop.image = UIImage(systemName: "gear")
        default:
            break
        }
        return cell
    }
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchText: UITextField!{
        didSet{
            searchText.placeholder = NSLocalizedString("輸入搜尋地方", comment: "")
            addDoneButtonOnKeyboard()
        }
    }

    var data: [String]!
    var baraddress : String!
    let locationManager = CLLocationManager()
    let studioAnnotation = MKPointAnnotation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //主畫面
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        data = []
        data.append(NSLocalizedString("酒吧清單", comment: ""))
        data.append(NSLocalizedString("月曆", comment: ""))
        data.append(NSLocalizedString("調酒清單", comment: ""))
        data.append(NSLocalizedString("設定", comment: ""))
        
        //地圖
        
        guard CLLocationManager.locationServicesEnabled() else {return}

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.delegate = self
    }
    
    
    
    private func zoomToLocation(location:CLLocationCoordinate2D?) {
           guard let location = location else { return }
           let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200,longitudinalMeters: 200)
           mapView.setRegion(viewRegion, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if case indexPath.row = 0 {
            
            let no1 = self.storyboard?.instantiateViewController(withIdentifier: "BarListViewController") as! BarListViewController
            self.navigationController?.pushViewController(no1, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else if case indexPath.row = 1 {
            
            let no2 = self.storyboard?.instantiateViewController(withIdentifier: "MonthlycalendarViewController") as! MonthlycalendarViewController
            self.navigationController?.pushViewController(no2, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else if case indexPath.row = 2{
            
            let no3 = self.storyboard?.instantiateViewController(withIdentifier: "BartendinglistViewController") as! BartendinglistViewController
            self.navigationController?.pushViewController(no3, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else if case indexPath.row = 3{
            
        let no4 = self.storyboard?.instantiateViewController(withIdentifier: "SetViewController") as! SetViewController
        self.navigationController?.pushViewController(no4, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
    }

    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let currentLocation :CLLocation = locations[0]
        let range:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation = currentLocation.coordinate
        let appearRegion:MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: range)

        mapView.setRegion(appearRegion, animated: true)
    }
    

    
    @IBAction func search(_ sender: UIButton) {
        searchText.endEditing(true)
        
        if searchText.text == nil {return}
        
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText.text!
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response: MKLocalSearch.Response?, error: Error?) in
            if error == nil && response != nil {
                
                for item in response!.mapItems {
                    self.zoomToLocation(location: item.placemark.coordinate)
                    self.mapView.addAnnotation(item.placemark)
                }
            }
        })
    }
    
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {return nil}
        var studioAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Studio")
        if studioAnnotationView == nil {
            studioAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Studio")
        }
        
        if annotation.title == annotation.title {
            baraddress = annotation.title ?? nil
            let label = UILabel()
            label.text = searchText.text
            label.font = UIFont(name: "PingFangTC-Medium", size: 14)
            studioAnnotationView?.detailCalloutAccessoryView = label
            
            // 設定右方按鈕
            let button = UIButton(type: .detailDisclosure)
            studioAnnotationView?.rightCalloutAccessoryView = button
        }
        studioAnnotationView?.canShowCallout = true
        return studioAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let controller = UIAlertController(title: "", message: NSLocalizedString("選擇功能", comment: ""), preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("導航", comment: ""), style: .default) { (action:UIAlertAction) in
            
            let gecoder1 = CLGeocoder()
            gecoder1.geocodeAddressString(self.baraddress) { (placemarks, error) in
                           if let error = error {
                            let alert = UIAlertController(title: "無法導航到此地點", message: "\(error.localizedDescription)", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true)
                               return
                           }
                           guard let placemark = placemarks?.first,let coordinate = placemark.location?.coordinate else{
                                   assertionFailure("Invalid placemark")
                                   return
                           }
                print("選擇的位置座標:\(coordinate.latitude),\(coordinate.longitude)")
                //終點座標
                let  targetCoordinate = CLLocationCoordinate2D (latitude: coordinate.latitude, longitude: coordinate.longitude)
                // 初始化 MKPlacemark
                let targetPlacemark = MKPlacemark(coordinate: targetCoordinate)
                // 透過 targetPlacemark 初始化一個 MKMapItem
                let targetItem = MKMapItem(placemark: targetPlacemark)
                // 使用當前使用者當前座標初始化 MKMapItem
                let userMapItem = MKMapItem.forCurrentLocation()
                // 建立導航路線的起點及終點 MKMapItem
                let routes = [userMapItem,targetItem]
                // 選擇導航模式
                MKMapItem.openMaps(with: routes, launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
            }
        }
         controller.addAction(deleteAction)
        let deleteAction2 = UIAlertAction(title: NSLocalizedString("新增酒吧資料", comment: ""), style: .default) { (action:UIAlertAction) in
            let gecoder1 = CLGeocoder()
            var address: String?
            gecoder1.geocodeAddressString(self.baraddress) { (placemarks, error) in
                if let error = error {
                    print("geocodeAddressString:\(error)")
                    return
                }
                guard let placemark = placemarks?.first,let coordinate = placemark.location?.coordinate else{
                    assertionFailure("Invalid placemark")
                    return
                }
                print("選擇的位置座標:\(coordinate.latitude),\(coordinate.longitude)")
                address = "\(placemark.postalCode ?? "n/a")\(placemark.subAdministrativeArea ?? "n/a")\(placemark.locality ?? "n/a")\(placemark.name ?? "n/a")"
                print("\(address)")
                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "barSecondView") as? BarSecondViewController{
                    self.navigationController?.pushViewController(controller, animated: true)
                    controller.address = address
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
       controller.addAction(deleteAction2)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("完成", comment: ""), style: .done,target: self,action: #selector(doneButtonAction))
        
        var items:[UIBarButtonItem] = []
        
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.searchText.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.searchText.resignFirstResponder()
    }
}

