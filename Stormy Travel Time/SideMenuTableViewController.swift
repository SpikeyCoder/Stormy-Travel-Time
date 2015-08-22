//
//  SideMenuTableViewController.swift
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/16/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//
enum CellTypes: String {
    case AddressCell = "findAddressCell", TravelTypeCell = "travelTypeCell", DirectionsCell = "directionsCell", MapTypeCell = "mapTypeCell"
}


import UIKit

class SideMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 4
    }
    
    func findAddressCellPressed()
    {
        NSNotificationCenter.defaultCenter().postNotificationName("com.StormyTravelTime.findAddress", object: nil)
    }
    
    func travelTypeCellPressed()
    {
        NSNotificationCenter.defaultCenter().postNotificationName("com.StormyTravelTime.travelType", object: nil)
    }
    
    func directionsCellPressed()
    {
        NSNotificationCenter.defaultCenter().postNotificationName("com.StormyTravelTime.directions", object: nil)
    }
    
    func mapTypeCellPressed()
    {
        NSNotificationCenter.defaultCenter().postNotificationName("com.StormyTravelTime.mapType", object: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
        {
            switch selectedCell.reuseIdentifier!
            {
                case CellTypes.AddressCell.rawValue:
                    self.findAddressCellPressed()
                    break
                case CellTypes.TravelTypeCell.rawValue:
                    self.travelTypeCellPressed()
                    break
                case CellTypes.DirectionsCell.rawValue:
                    self.directionsCellPressed()
                    break
                case CellTypes.MapTypeCell.rawValue:
                    self.mapTypeCellPressed()
                    break
                default:
                    break
            }

        }
}

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
