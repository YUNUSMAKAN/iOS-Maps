//
//  ViewController.swift
//  HARiTALAR
//
//  Created by MAKAN on 2.11.2020.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    
    var locationManager = CLLocationManager() //CLLocation CoreLocation dan gelen bir objedir.Konum ile alakali islemlerde kullanilir.Kullanicin konumunu alicaksak, kullanicin konumu ile ilgili islemler yapicaksak, ve bu kendi haritamizda gostericeksek bunu kullanmamiz gerekiyor.
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
//  MARK:- LOCATION ALMA ISLEMLERI.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Kullanicinin konumunu en dogru/en iyi sekilde almak icin bunu kullaniyoruz.
        locationManager.requestWhenInUseAuthorization() //Kullanicidan lokasyonunu almak icin izin isteme islemi.
        locationManager.startUpdatingLocation() //Kullanicinin yerini almaya baslariz.
        
//   MARK:- PIN EKLEME ISLEMI.
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choosenLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3 //Kac saniye basarsa algilasin onu belirtiyoruz.
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func choosenLocation(gestureRecognizer:UILongPressGestureRecognizer) { // fonk icine input olarak verdik, bu secilde gestureRecognizer in kendi metodlarina, attributes larina ulasabiliriz.
        
        // Tiklanilan yerin kordinatlarini almak istiyoruz ve Pin olusturalim.Ve bu pin i haritamiza ekliyelim istedigimiz/yapacagimiz islem budur.
        if gestureRecognizer.state == .began {//state: guncel icinde bulundugu durumu kontrol ederiz.began diyerek basmaya basladi mi onu kontrol ederiz.
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView) //Dokunulan noktalari aliriz.
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView) //Dokunulan noktalari kordinata cevirme islemi.Dokunal yerin kordinatlarini aliriz.
            choosenLatitude = touchedCoordinates.latitude //Kullanici her dokundagunda otomatik olarak choosenLatitude/Longitude degiskenleride son dokunulan yerin kordinatlarina gore degisecekdir.En son tikladigimizi COREDATA YA kaydedicek sonuc olarak.
            choosenLongitude = touchedCoordinates.longitude
            
        // Annotation ekleme islemi.
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameTextField.text
            annotation.subtitle = commentTextField.text
            self.mapView.addAnnotation(annotation)
            
            
        }
    }
    
//MARK:- KULLANICININ KONUMUNU ALARAK NE YAPACAGIMIZI BU FONSIYONDA YAPIYORUZ.YANI BIR KULLANICININ LOCATION I OLUSTURUCAZ HARITADA VE HARITADA ZOOM LAMA ISLEMINI YAPICAZ.YANI O ANKI KONUMU NEREDE ISE HARITA ORADA ACILMA ISLEMINI YAPICAZ.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Guncellenen locationlari [CLLocation] dizisi icinde veriyor.Devamli lokasyon guncellendigi icin surekli guncelleniyor.
        
        // locations[0] //Bu bana en guncel location'i vericektir.CLLocation objesi vericektir. CLLocation : Icerisinde latitude ve longitude barindiran bir objedir.Haritalar ve locationlar ile calisirken hep latitude ve longitude lar ile calisiriz.
                
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //Konum olusturmamiza yarar.
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //Haritada isterilen yeri zoom layip gosterme islemi ne span denir.Deger ne kadar kucuk olursa o kadar zoomlama yapar.ZOOM lama seviyesi diyebiliriz.
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
//    MARK:- DOKUNULAN YERLERI COREDATA YA KAYDETME ISLEMI.
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context) //Kullanicinin kaydetmek istedigi verileri koyucagimiz yer.
//      CoreData ya kaydettigimiz seyler asagidakilerdir.
        newPlace.setValue(nameTextField.text, forKey: "title") //Istedigimiz anahtar kelimeye karsilik istedigimiz degerleri kaydedebiliyoruz.
        newPlace.setValue(commentTextField.text, forKey: "subtitle")//Istersen bos/bos degil ise comment text alert mesaji felan gosterirsek daha dogru bir kullanim olur.
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("SUCCESS!")
        }catch {
            print("ERROR!")
        }
    }
}

