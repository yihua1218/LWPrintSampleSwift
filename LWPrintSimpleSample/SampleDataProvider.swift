/**
* @file SampleDataProvider.swift
* @brief LWPrintSampleSwift SampleDataProvider Class definition
* @par Copyright:
* Copyright (C) SEIKO EPSON CORPORATION 2019. All rights reserved.<BR>
*/

import Foundation

class SampleDataProvider: LWPrintDataProvider
{
    enum FormType
    {
        case string
        case qrCode
        case qrCodeX10
    }
    
    // MARK: public member
    var formType: FormType = .string
    var stringData: String? = "String"
    var qrCodeData: String? = "QRCode"
    var qrCodeX10Data: String? = "QRCodeX10"
    
    var qrCodeX10DataArray: [String] = [
        "https://yihua.app/28utTe",
        "https://yihua.app/PrwV7u",
        "https://yihua.app/kNbG5R",
        "https://yihua.app/ClMpBf",
        "https://yihua.app/jPqsW1",
        "https://yihua.app/bqHsI8",
        "https://yihua.app/7ZgceT",
        "https://yihua.app/pHUaSz",
        "https://yihua.app/ghEmny",
        "https://yihua.app/6tl08N",
    ]
    
    var codeIndex = 0
    
    // MARK: private member
    fileprivate var formDataString: [String: AnyObject]?
    fileprivate var formDataQRCode: [String: AnyObject]?
    fileprivate var formDataQRCodeX10: [String: AnyObject]?
    
    // MARK: override method
    override init()
    {
        if let _formPath = Bundle.main.path(forResource: "FormDataString", ofType: "plist")
        {
            formDataString = NSDictionary(contentsOfFile: _formPath) as? [String: AnyObject]
        }
        if let _formPath = Bundle.main.path(forResource: "FormDataQRCode", ofType: "plist")
        {
            formDataQRCode = NSDictionary(contentsOfFile: _formPath) as? [String: AnyObject]
        }
        if let _formPath = Bundle.main.path(forResource: "FormDataQRCodeX10", ofType: "plist")
        {
            formDataQRCodeX10 = NSDictionary(contentsOfFile: _formPath) as? [String: AnyObject]
        }
    }
    
    override func startOfPrint()
    {
        // It is called only once when printing started
        print("<startOfPrint()>")
    }
    
    override func endOfPrint()
    {
        // It is called only once when printing finished
        print("<endOfPrint()>")
    }
    
    override func startPage()
    {
        // It is called when starting a page
        print("<startPage()>")
    }
    
    override func endPage()
    {
        // It is called when finishing a page
        print("<endPage()>")
    }
    
    override func numberOfPages() -> Int
    {
        // Return all pages printed
        print("<numberOfPages()>")
        return 1
    }
    
    override func formData(forPage pageIndex: Int) -> [AnyHashable: Any]!
    {
        // Return the form data for pageIndex page
        print("<formDataForPage>pageIndex=\(pageIndex)")
        
        var formData: [AnyHashable: Any]!
        
        switch formType
        {
        case .string:
            formData = formDataString
        case .qrCode:
            formData = formDataQRCode
        case .qrCodeX10:
            formData = formDataQRCodeX10
        }
        
        return formData
    }
    
    override func contentData(_ contentName: String!, forPage pageIndex: Int) -> Any!
    {
        // Return the data for the contentName of the pageIndex page
        print("<contentData(_:forPage:)>contentName=\(contentName!),pageIndex=\(pageIndex)")
        if contentName == "String"
        {
            return stringData as AnyObject
        }
        else if contentName == "QRCode"
        {
            return qrCodeData as AnyObject
        }
        else if contentName == "QRCodeX10"
        {
            let tempIndex = codeIndex % qrCodeX10DataArray.count
            codeIndex += 1
            return qrCodeX10DataArray[tempIndex] as AnyObject
        }
        return nil
    }
}
