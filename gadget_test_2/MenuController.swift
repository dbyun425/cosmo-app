//
//  MenuController.swift
//  gadget_test_2
//
//  Created by Doyee Byun on 3/14/17.
//  Copyright © 2017 Peter Lee. All rights reserved.
//

import UIKit


class MenuController: UIViewController {
    @IBOutlet weak var initCond1: UIButton!
    
    @IBAction func beforeStage1(_ sender: Any) {
        playing = 1
        level = 1
    }
    @IBAction func beforeStage2(_ sender: Any) {
        playing = 1
        level = 2
    }
    @IBAction func beforeStage3(_ sender: Any) {
        playing = 1
        level = 3
    }
    @IBAction func beforeStage4(_ sender: Any) {
        playing = 1
        level = 4
    }
    
    @IBAction func getout(_ sender: UIBarButtonItem) {
        print("pls")
    }
    
    @IBAction func unwindSegue(unwindSegue:UIStoryboardSegue)
    {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playing = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
