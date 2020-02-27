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
    }
    
    // MARK: public member
    var formType: FormType = .string
    var stringData: String? = "String"
    var qrCodeData: String? = "QRCode"
    
    // MARK: private member
    fileprivate var formDataString: [String: AnyObject]?
    fileprivate var formDataQRCode: [String: AnyObject]?
    
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
        return nil
    }
}
