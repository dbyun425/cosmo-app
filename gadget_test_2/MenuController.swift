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
        Gamestate.levelcode = 1
    }
    @IBAction func beforeStage2(_ sender: Any) {
        Gamestate.levelcode = 2
    }
    
    @IBAction func unwindSegue(unwindSegue:UIStoryboardSegue)
    {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
