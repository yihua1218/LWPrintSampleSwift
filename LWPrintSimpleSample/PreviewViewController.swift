//
//  PreviewViewController.swift
//  LWPrintSimpleSample
//
//  Created by LW_Admin on 2019/02/05.
//  Copyright © 2019年 SEIKO EPSON CORPORATION. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, LWPrintDelegate {
    
    // MARK: IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: private member
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        // Get print image from dataProvider
        imageView.image = image
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
