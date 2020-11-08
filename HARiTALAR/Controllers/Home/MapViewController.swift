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

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    
    var locationManager = CLLocationManager() //CLLocation CoreLocation dan gelen bir objedir.Konum ile alakali islemlerde kullanilir.Kullanicin konumunu alicaksak, kullanicin konumu ile ilgili islemler yapicaksak, ve bu kendi haritamizda gostericeksek bunu kullanmamiz gerekiyor.
    //MARK:- TIKLANILAN/SECILEN YERIN KORDINATLARINI ALMAK ICIN OLUSTURDUGUMUZ DEGISKENLER.
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    //MARK:- SECILEN YERIN BILGILERINE GITMESI ICIN OLUSTURDUGUMUZ DEGISKEN.SECILEN YER BOS ISE ARKADAS YERI BIR YER EKLEMEYE CALISIYOR, EGER SECILEN YER DOLUYSA BASKA BIR SEY GOSTERMEYE/ESKISINI GOSTEMEYE CALISIYOR CALISIYOR.
    var selectedTitle = ""
    var selectedTitleId : UUID?
//    MARK:-SECILEN YERIN ANNOTATIONINI HARITADA GOSTERME ISLEMI.
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        showData()
        
//   MARK:- LOCATION ALMA ISLEMLERI.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Kullanicinin konumunu en dogru/en iyi sekilde almak icin bunu kullaniyoruz.
        locationManager.requestWhenInUseAuthorization() //Kullanicidan lokasyonunu almak icin izin isteme islemi.
        locationManager.startUpdatingLocation() //Kullanicinin yerini almaya baslariz.
        
//   MARK:- PIN EKLEME ISLEMI.
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choosenLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3 //Kac saniye basarsa algilasin onu belirtiyoruz.
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func choosenLocation(gestureRecognizer:UILongPressGestureRecognizer) { // Fonk icine input olarak verdik, bu secilde gestureRecognizer in kendi metodlarina, attributes larina ulasabiliriz.
        
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
    
    func showData(){
        if selectedTitle != "" {
//            Bos degil ise COREDATADAN CEKME ISLEMINI YAPICAZ.Add button dan gidiyorsa bos yollamamiz lazim, eger tableviewdan gidiyorsa dolu yollamamiz lazim.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@" , idString)//filtre ekledik.Yani sadece biim istedigimiz id si istedimiz idstringine esit olan arkadaslari cegir dedik.
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        //hersey olduyse asagidakini yapicak ve annotation i olusturucak.
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        
                                        nameTextField.text = annotationTitle
                                        commentTextField.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation() //Belirlenen konuma gitsin, yani kullanicinin guncel konumuna gore haritasinin yeri degismesin diye yaptik.
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                        
                        
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }catch {
                print("ERROR!")
            }
            
            
        }else{
//            Bos ise birsey yapmamiza gerek yok.Yeni yer ekleme islemi olmus oluyor.
        }
    }
    
//MARK:- KULLANICININ KONUMUNU ALARAK NE YAPACAGIMIZI BU FONSIYONDA YAPIYORUZ.YANI BIR KULLANICININ LOCATION I OLUSTURUCAZ HARITADA VE HARITADA ZOOM LAMA ISLEMINI YAPICAZ.YANI O ANKI KONUMU NEREDE ISE HARITA ORADA ACILMA ISLEMINI YAPICAZ.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Guncellenen locationlari [CLLocation] dizisi icinde veriyor.Devamli lokasyon guncellendigi icin surekli guncelleniyor.
        
        // locations[0] //Bu bana en guncel location'i vericektir.CLLocation objesi vericektir. CLLocation : Icerisinde latitude ve longitude barindiran bir objedir.Haritalar ve locationlar ile calisirken hep latitude ve longitude lar ile calisiriz.
        if selectedTitle == "" {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //Konum olusturmamiza yarar.
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //Haritada isterilen yeri zoom layip gosterme islemi ne span denir.Deger ne kadar kucuk olursa o kadar zoomlama yapar.ZOOM lama seviyesi diyebiliriz.
        let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            
        }else {
            
        }
    }
//    MARK:- ANNOTATION OZELLESTIRME ISLEMI.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {// MKUserLocation:Kullanicin yerini gosteren annotation.
            return nil //kullanicinin yerini pin ile gostermek istemiyorum dedik.Nereye tikladiysam orayi gostermek istiyorum.
        }
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
                    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    pinView?.canShowCallout = true //Callout :Bir baloncuk ile birlikte ekstra bilgi gosterebilecegimiz bir yer.
                    pinView?.tintColor = UIColor.red
                    
                    let button = UIButton(type: UIButton.ButtonType.detailDisclosure) //detailDisclosure: detay gosterecegim button
                    pinView?.rightCalloutAccessoryView = button
                    
                }else {
                    pinView?.annotation = annotation
                }
        
        return pinView
    }
    
//   MARK:- PINDEKI ACIKLAMA BALONUNDAKI BUTONA TIKLANINCA NE OLACAGINI/TIKLANDIGINI ALGILAYARAK NE YAPACAGIMIZI BELIRTTIGIMIZ FONK.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {//calloutAccessoryControlTapped : oraya tiklandi demek.Oraya tiklandiysa ne olacagini yazacaz.
        if selectedTitle != "" {//Secilen yer bos deil ise Yani latitude ve longtidu vardir demek oluyor bu.
             
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            //CLGeocoder: Kordinatlar ile yerler arasinda baglanti kurmamaiza yarayan bir siniftir.
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in //Bu yapinin adina closure denir.
                //closure : biz bir islem yapiyoruz sonucunda bize birsey verilecek.Ya error yada placemark dizisi verilicek.
                
                if let placemark = placemarks {
                if placemark.count > 0 {
                    
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.annotationTitle //item i kullanarak navigasyonu acabilirim.
                    let launcOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving] //nasil bir navigasyon yapicagimizi yazmamiz gerekiyor.Araba ile gidicegimiz belirttik.
                    item.openInMaps(launchOptions: launcOptions)
                    
                    
                    
                }
            }
            
        }
        
    }
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
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil) //butun app e bir mesaj yolluyo diger tarafda bir OBSERVER kullanarak newPlace mesaji gelince ne yapicagimizi soyluyorduk.
        navigationController?.popViewController(animated: true) //bir onceki VC ye geri goturecek.Yni List VC ye.
    }
    
    
}

