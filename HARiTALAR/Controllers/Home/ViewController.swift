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
//  MARK:- LOCATION ALMA ISLEMLERI.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Kullanicinin konumunu en dogru/en iyi sekilde almak icin bunu kullaniyoruz.
        locationManager.requestWhenInUseAuthorization() //Kullanicidan lokasyonunu almak icin izin isteme islemi.
        locationManager.startUpdatingLocation() //Kullanicinin yerini almaya baslariz.
        
    }
    
//MARK:- KULLANICININ KONUMUNU ALARAK NE YAPACAGIMIZI BU FONSIYONDA YAPIYORUZ.YANI BIR KULLANICININ LOCATION I OLUSTURUCAZ HARITADA VE HARITADA ZOOM LAMA ISLEMINI YAPICAZ.YANI O ANKI KONUMU NEREDE ISE HARITA ORADA ACILMA ISLEMINI YAPICAZ.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Guncellenen locationlari [CLLocation] dizisi icinde veriyor.Devamli lokasyon guncellendigi icin surekli guncelleniyor.
        
        // locations[0] //Bu bana en guncel location'i vericektir.CLLocation objesi vericektir. CLLocation : Icerisinde latitude ve longitude barindiran bir objedir.Haritalar ve locationlar ile calisirken hep latitude ve longitude lar ile calisiriz.
                
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //Konum olusturmamiza yarar.
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //Haritada isterilen yeri zoom layip gosterme islemi ne span denir.Deger ne kadar kucuk olursa o kadar zoomlama yapar.ZOOM lama seviyesi diyebiliriz.
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        

        
    }

}

