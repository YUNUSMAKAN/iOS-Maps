//
//  ViewController.swift
//  HARiTALAR
//
//  Created by MAKAN on 2.11.2020.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager() //CLLocation CoreLocation dan gelen bir objedir.Konum ile alakali islemlerde kullanilir.Kullanicin konumunu alicaksak, kullanicin konumu ile ilgili islemler yapicaksak, ve bu kendi haritamizda gostericeksek bunu kullanmamiz gerekiyor.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Kullanicinin konumunu en dogru/en iyi sekilde almak icin bunu kullaniyoruz.
    }
    
//MARK:- KULLANICININ KONUMUNU ALMA ISLEMI.YANI O ANKI KONUMU NEREDE ISE HARITA ORADA ACILACAK.

}

