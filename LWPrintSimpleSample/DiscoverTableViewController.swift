/**
* @file DiscoverTableViewController.swift
* @brief LWPrintSampleSwift DiscoverTableViewController Class definition
* @par Copyright:
* Copyright (C) SEIKO EPSON CORPORATION 2019. All rights reserved.<BR>
*/


import UIKit

@objc protocol DiscoverTableViewControllerDelegate: NSObjectProtocol
{
    @objc optional func discoverView(_ discoverView: DiscoverTableViewController, didSelectPrinter printerInfo: [String: AnyObject])
}

class DiscoverTableViewController: UITableViewController, LWPrintDiscoverPrinterDelegate
{
    // MARK: public member
    var delegate: DiscoverTableViewControllerDelegate?
    
    // MARK: private member
    fileprivate let CELL_IDENTIFIER = "DiscoverPrinteCell"
    
    fileprivate var discover: LWPrintDiscoverPrinter!
    fileprivate var printers: [[String : AnyObject]]!
    
    // MARK: override method
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if printers == nil
        {
            printers = Array()
        }
        
        // Create the object for LWPrintDiscoverPrinter
        if discover == nil
        {
            // models:  Specify the printing model name of retrieval object with array
            //          In terms of nil, all printers compatible would be object retrieval
            // connectionType:  Specify the printing type of searching object with LWPrintDiscoverConnectionType
            discover = LWPrintDiscoverPrinter(models: nil, connectionType: LWPrintDiscoverConnectionType())
            discover.delegate = self
        }
        // Begin search for a printer
        discover.startDiscover()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return printers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell! = nil
        let printer = printers[indexPath.row]
        cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: CELL_IDENTIFIER)
        }
        cell.detailTextLabel?.text = printer[LWPrintPrinterInfoType] as? String
        cell.textLabel?.text = printer[LWPrintPrinterInfoBonjourName] as? String
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let printerInfo = printers[indexPath.row]
        if let _delegate = delegate
        {
            _delegate.discoverView?(self, didSelectPrinter: printerInfo)
        }
        // Finish search for a printer
        discover.stopDiscover()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: LWPrintDiscoverPrinterDelegate
    func discoverPrinter(_ discoverPrinter: LWPrintDiscoverPrinter!, didFindPrinter printerInformation: [AnyHashable: Any]!)
    {
        // Notify when finding out a printer
        guard let findPrinterInformation = printerInformation else
        {
            return
        }
        
        printers.append(findPrinterInformation as! [String : AnyObject])
        self.tableView.reloadData()
    }
    
    func discoverPrinter(_ discoverPrinter: LWPrintDiscoverPrinter!, didRemovePrinter printerInformation: [AnyHashable: Any]!)
    {
        // Notify when loosing sight of a printer
        guard let removePrinterInformation = printerInformation else
        {
            return
        }
        
        for (index, registeredInformation) in printers.enumerated()
        {
            if (removePrinterInformation as NSDictionary).isEqual(to: registeredInformation)
            {
                printers.remove(at: index)
                break
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: IBAction
    @IBAction func doneButton(_ sender: AnyObject)
    {
        // Finish search for a printer
        discover.stopDiscover()
        self.navigationController?.popViewController(animated: true)
    }
}
