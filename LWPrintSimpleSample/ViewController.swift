/**
* @file ViewController.swift
* @brief LWPrintSampleSwift ViewController Class definition
* @par Copyright:
* Copyright (C) SEIKO EPSON CORPORATION 2019. All rights reserved.<BR>
*/

import UIKit

class ViewController: UIViewController, LWPrintDelegate, DiscoverTableViewControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    // MARK: IBOutlet
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var selectDataText: UITextField!
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    
    // MARK: private member
    fileprivate let SHARED_LWPRINT: LWPrint = LWPrint()
    fileprivate let DATA_PROVIDER: SampleDataProvider = SampleDataProvider()
    
    fileprivate var processing: Bool = false
    fileprivate var printerInfo: [String: AnyObject]?
    
    let dataList = ["Text", "QRCode", "QRCodeX10", "Img1", "Img2"];
    var pickerView: UIPickerView = UIPickerView()
    var selectData:DataType = .text
    
    enum ProcessType
    {
        case ptint
        case preview
    }
    
    enum DataType
    {
        case text
        case qrcode
        case qrcodex10
        case img1
        case img2
    }
    
    // MARK: override method
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        dataTextField.text = sharedDataProvider().stringData
        
        let toolbar = UIToolbar(frame: CGRect(x:0,y:0,width:0,height:35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.done))
        toolbar.setItems([doneItem], animated: true)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        selectDataText.inputView = pickerView
        selectDataText.inputAccessoryView = toolbar
        selectDataText.text = dataList[0]
    }
    
    @objc func done()
    {
        selectDataText.endEditing(true)
    }
    
    // MARK: UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: UIPickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    // MARK: UIPickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    // MARK: UIPickerView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectData = intToDataType(num: row)
        selectDataText.text = dataList[row]
        switch selectData {
        case .text:
            dataTextField.text = sharedDataProvider().stringData
            break;
        case .qrcode:
            dataTextField.text = sharedDataProvider().qrCodeData
            break;
        case .qrcodex10:
            dataTextField.text = sharedDataProvider().qrCodeX10Data
            break;
        default:
            dataTextField.text = ""
            break;
        }
    }
    
    func intToDataType(num: Int) -> DataType
    {
        let ret: DataType
        switch num {
        case 1:
            ret = .qrcode
            break
        case 2:
            ret = .qrcodex10
            break
        case 3:
            ret = .img1
            break
        case 4:
            ret = .img2
            break
        default:
            ret = .text
        }
        return ret
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        discoverButton.setTitle("Select: Device is not selected", for: UIControl.State())
        if let _printerInfo = printerInfo
        {
            if let _bonjourName = _printerInfo["BonjourName"] as? String
            {
                discoverButton.setTitle(String(format: "Select:%@", _bonjourName), for: UIControl.State())
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        dataTextField.resignFirstResponder()
        if (segue.identifier == "preview")
        {
            let previewView = segue.destination as! PreviewViewController
            previewView.image = sender as? UIImage
        }
        if segue.identifier == "DiscoverPrinter"
        {
            let discoverView = segue.destination as! DiscoverTableViewController
            discoverView.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IBAction
    @IBAction func doPrint(_ sender: AnyObject)
    {
        dataTextField.resignFirstResponder()
        setProcessing(true)
        
        performPrint(process: .ptint)
    }
    
    @IBAction func setCustomData(_ sender: AnyObject)
    {
        if selectData == .qrcode
        {
            sharedDataProvider().qrCodeData = dataTextField.text
        }
        else if selectData == .qrcodex10
        {
            sharedDataProvider().qrCodeX10Data = dataTextField.text
        }
        else if selectData == .text
        {
            sharedDataProvider().stringData = dataTextField.text
        }
    }
    
    // MARK: IBAction
    @IBAction func doPreview(_ sender: AnyObject)
    {
        dataTextField.resignFirstResponder()
        setProcessing(true)
        
        performPrint(process: .preview)
    }
    
    // MARK: DiscoverTableViewControllerDelegate
    func discoverView(_ discoverView: DiscoverTableViewController, didSelectPrinter printerInfo: [String: AnyObject])
    {
        self.printerInfo = printerInfo
    }
    
    // MARK: LWPrintDelegate
    func lwPrint(_ lwPrint: LWPrint!, didChangePrintOperationPhase jobPhase: LWPrintPrintingPhase)
    {
        // Report the change of a printing phase
        var phase = ""
        
        switch jobPhase
        {
        case LWPrintPrintingPhase.PrintingPhasePrepare:
            phase = "PrintingPhasePrepare"
        case LWPrintPrintingPhase.PrintingPhaseProcessing:
            phase = "PrintingPhaseProcessing"
        case LWPrintPrintingPhase.PrintingPhaseWaitingForPrint:
            phase = "PrintingPhaseWaitingForPrint"
        case LWPrintPrintingPhase.PrintingPhaseComplete:
            phase = "PrintingPhaseComplete"
            self.printComplete(LWPrintConnectionStatus.ConnectionStatusNoError, deviceStatus: LWPrintStatusError.StatusErrorNoError, isSuspend: false)
            self.setProcessing(false)
        }
        
        print("<lwPrint(_:didChangePrintOperationPhase:)>phase=\(phase)")
    }
    
    func lwPrint(_ lwPrint: LWPrint!, didAbortPrintOperation errorStatus: LWPrintConnectionStatus, deviceStatus: LWPrintStatusError)
    {
        // It is called when undergoing a transition to the printing cancel operation due to a printing error
        self.printComplete(errorStatus, deviceStatus: deviceStatus, isSuspend: false)
        
        self.setProcessing(false)
        
        let message = String(format: "Error Status : %d\nDevice Status : %02X", errorStatus.rawValue, deviceStatus.rawValue)
        let alert: UIAlertController = UIAlertController(title: "Print Error!", message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
            lwPrint.cancel()
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func lwPrint(_ lwPrint: LWPrint!, didSuspendPrintOperation errorStatus: LWPrintConnectionStatus, deviceStatus: LWPrintStatusError)
    {
        // It is called when undergoing a transition to the printing restart operation due to a printing error
        self.printComplete(errorStatus, deviceStatus: deviceStatus, isSuspend: true)
        
        let message = String(format: "Error Status : %d\nDevice Status : %02X", errorStatus.rawValue, deviceStatus.rawValue)
        let alert: UIAlertController = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
            lwPrint.cancel()
        })
        let defaultAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
            lwPrint.resumeOfPrint()
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if selectData == .text
        {
            sharedDataProvider().stringData = dataTextField.text
        }
        else if selectData == .qrcode
        {
            sharedDataProvider().qrCodeData = dataTextField.text
        }
        else if selectData == .qrcodex10
        {
            sharedDataProvider().qrCodeX10Data = dataTextField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: public method
    func getProcessing() -> Bool
    {
        return processing
    }
    
    // MARK: private method
    fileprivate func performPrint(process :ProcessType)
    {
        guard let printerInfo = self.printerInfo else
        {
            let message = String(format: "Device is not selected.")
            let alert: UIAlertController = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertController.Style.alert)
            let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                let lwPrint = self.sharedLWPrint()
                lwPrint.cancel()
            })
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
            setProcessing(false)
            return
        }
        
        DispatchQueue.global(qos: .default).async { () -> Void in
            
            let lwPrint = self.sharedLWPrint()
            var image: UIImage? = nil
            
            // Set printing information
            lwPrint.setPrinterInformation(printerInfo)
            
            // Obtain printing status
            guard let lwStatus = lwPrint.fetchPrinterStatus() else
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let message = String(format: "Can't get printer status.")
                    let alert: UIAlertController = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertController.Style.alert)
                    let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                        lwPrint.cancel()
                    })
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    self.setProcessing(false)
                })
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                let dataProvider = self.sharedDataProvider()
                switch self.selectData
                {
                case .qrcode:
                    dataProvider.formType = .qrCode
                    break
                case .qrcodex10:
                    dataProvider.formType = .qrCodeX10
                    break
                case .img1:
                    image = UIImage(named: "work_108x108.png")
                    break
                case .img2:
                    image = UIImage(named: "image_120x108.png")
                    break
                default:
                    dataProvider.formType = .string
                    break
                }
                
                // Make a print parameter
                let tapeWidth = lwPrint.tapeWidth(fromStatus: lwStatus)
                lwPrint.delegate = self
                
                let printParameter: [String: AnyObject] = [
                    LWPrintParameterKeyCopies: 1 as AnyObject,                                           // Number of copies(1 ... 99)
                    LWPrintParameterKeyTapeCut: LWPrintTapeCut.TapeCutEachLabel.rawValue as AnyObject,   // Tape cut method(LWPrintTapeCut)
                    LWPrintParameterKeyHalfCut: true as AnyObject,                                       // Set half cut (true:half cut on)
                    LWPrintParameterKeyPrintSpeed: false as AnyObject,                                   // Low speed print setting (true:low speed print on)
                    LWPrintParameterKeyDensity: 0 as AnyObject,                                          // Print density(-5 ... 5)
                    LWPrintParameterKeyTapeWidth: tapeWidth.rawValue as AnyObject,                       // Tape width(LWPrintTapeWidth)
                ]

                if (process == .ptint)
                {
                    // Carry out printing
                    if (image != nil) {
                        let data: Data! = image!.pngData()! as Data
                        lwPrint.do(printParameter, print: data)
                    } else {
                        lwPrint.do(dataProvider, printParameter: printParameter)
                    }
                } else {
                    // Carry out preview
                    if (image == nil) {
                        let images:NSArray = lwPrint.labelImages(dataProvider, printParameter: printParameter)! as NSArray;
                        if (images.count > 0) {
                            image = images[0] as? UIImage;
                        }
                    }
                    self.performSegue(withIdentifier: "preview", sender: image)
                    self.setProcessing(false)
                }
            })
        }
    }
    
    fileprivate func sharedLWPrint() -> LWPrint
    {
        return SHARED_LWPRINT
    }
    
    fileprivate func sharedDataProvider() -> SampleDataProvider
    {
        return DATA_PROVIDER
    }
    
    fileprivate func setProcessing(_ value: Bool)
    {
        processing = value
        
        if processing == true
        {
            discoverButton.isEnabled = false
            dataTextField.isEnabled = false
            printButton.isEnabled = false
            selectDataText.isEnabled = false
            previewButton.isEnabled = false
        }
        else
        {
            discoverButton.isEnabled = true
            dataTextField.isEnabled = true
            printButton.isEnabled = true
            selectDataText.isEnabled = true
            previewButton.isEnabled = true
        }
    }
    
    fileprivate func printComplete(_ connectionStatus: LWPrintConnectionStatus, deviceStatus: LWPrintStatusError, isSuspend: Bool)
    {
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        if appDelegate.bgTask == UIBackgroundTaskIdentifier.invalid
        {
            return
        }
        
        let device = UIDevice.current
        let backgroundSupported = device.isMultitaskingSupported
        if !backgroundSupported
        {
            return
        }

        var msg = ""
        if connectionStatus == LWPrintConnectionStatus.ConnectionStatusNoError && deviceStatus == LWPrintStatusError.StatusErrorNoError
        {
            msg = "Print Complete."
        }
        else
        {
            if isSuspend
            {
                msg = String(format: "Print Error Re-Print [%02x].", deviceStatus.rawValue)
            }
            else
            {
                msg = String(format: "Print Error [%02x].", deviceStatus.rawValue)
            }
        }
        
        let alarm = UILocalNotification()
        alarm.fireDate = Date()
        alarm.timeZone = TimeZone.current
        alarm.repeatInterval = NSCalendar.Unit(rawValue: 0)
        alarm.soundName = "alarmsound.caf"
        alarm.alertBody = msg
        app.scheduleLocalNotification(alarm)
    }
}

