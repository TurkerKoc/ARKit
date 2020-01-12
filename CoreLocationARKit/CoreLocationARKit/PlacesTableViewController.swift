//
//  PlacesTableViewController.swift
//  CoreLocationARKit
//
//  Created by Turker Koc on 15.07.2019.
//  Copyright © 2019 Turker Koc. All rights reserved.
//

import Foundation
import UIKit

class PlacesTableViewController : UITableViewController
{
    private let places = ["Benzinlik","Kafe","Spor Salonu","Sinema","Park"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //determining colums
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    //assigning each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //also change name of the cell from MainStoryboard
        cell.textLabel?.text = self.places[indexPath.row]
        return cell
    }
    
    //to perform changing screeen to AR view we have to preapre segue to ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = (self.tableView.indexPathForSelectedRow)!
        let place = self.places[indexPath.row]
        
        let vc = segue.destination as! ViewController
        vc.place = place //Assigning which cell was chosen from PlacesVC
    }
    
}
