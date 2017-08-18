//
//  MenuController.swift
//  gadget_test_2
//
//  Created by Doyee Byun on 3/14/17.
//  Copyright © 2017 Peter Lee. All rights reserved.
//

import UIKit


class MenuController: UITableViewController {
    @IBOutlet weak var initCond1: UIButton!
    

    @IBAction func loadStage1(_ sender: UIButton) {
        playing = 1
        let str = sender.titleLabel?.text
        let intString = str?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        level = Int32(intString!)!
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
