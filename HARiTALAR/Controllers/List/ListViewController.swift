//
//  ListViewController.swift
//  HARiTALAR
//
//  Created by MAKAN on 4.11.2020.
//

import UIKit
import CoreData


class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    //VERI AKTARIMI/GOSTERIMI ICIN KULLANICAGIMIZ DEGISKENLER.
    var chosentTitle = ""
    var chosenTitleId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
//    MARK:- VIEWWILLAPPEAR HER GORUNUM GORUNDUGUNDE CAGIRILIR.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
//MARK:- Yeni yer eklemek icin.
    @objc func addButton() {
        chosentTitle = ""
        let vc = UIStoryboard.myStoryboardName.instantiateViewController(identifier: "MainVC") as! MapViewController
        vc.modalPresentationStyle = .fullScreen
        show(vc, sender: nil)
    }
    
    @ objc func getData() {
        
        let appDelegate = UIApplication.shared.delegate as!AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                
                    }
                    
                    tableView.reloadData()
                    
                }
            }
        }catch {
            print("ERROR!")
        }
       
    }
    
}
extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosentTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        let vc = UIStoryboard.myStoryboardName.instantiateViewController(identifier: "MainVC") as! MapViewController
        vc.modalPresentationStyle = .fullScreen
        vc.selectedTitle = chosentTitle
        vc.selectedTitleId = chosenTitleId
        show(vc, sender: nil)
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    
    
}
