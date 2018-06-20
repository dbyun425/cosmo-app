//
//  LevelSelectImgController.swift
//  gadget_test_2
//
//  Created by Ray Ye on 2/22/18.
//  Copyright © 2018 Peter Lee. All rights reserved.
//

import UIKit


class LevelSelectImgController: UIViewController {
    @IBOutlet weak var initCond1: UIButton!
    
    let testFd = "testReadWrite.txt";
    let appName = "Gadget Game";
    let fm = FileManager.default;
    
    var levelLength : Int = 0
    var levelArray : [String] = []
    let levelsFd = (Bundle.main.resourcePath! as NSString).appendingPathComponent("levels.txt")
    var isLevelsLoaded = false
    let buttonXOffset : Int = 30;
    let buttonYOffset : Int = 20;
    let buttonXMultip : Int = 70;
    let buttonYMultip : Int = 70;
    let buttonXDimen = 8;
    let buttonYDimen = 9;
    var buttonTotal : Int;
    var buttonXMax : Int;
    var buttonYMax : Int;
    
    let iconFd = (Bundle.main.resourcePath! as NSString).appendingPathComponent("galaxy.jpg")
    var iconImage : UIImage;
    let bsidedim = 50;
    
    func getLevels(){
        do{
            let contents = try NSString(contentsOfFile : levelsFd, encoding: String.Encoding.ascii.rawValue)
            contents.enumerateLines({(line,stop) -> () in self.levelArray.append(line)})
        } catch{
            print("ERROR: WRONG TEXT FILE")
        }
        self.levelLength = self.levelArray.count
        if(levelLength > 0){
            self.isLevelsLoaded = true
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var fileURL =  url.appendingPathComponent(appName);
        fileURL = fileURL.appendingPathComponent(testFd);
        var rowCount = 0;
        do{
            let contents = try NSString(contentsOfFile : fileURL.path, encoding: String.Encoding.ascii.rawValue)
            var curval = Int(contents as String);
            rowCount = curval! + 1
        } catch{
            print("ERROR: \(error)")
        }
        if(rowCount > self.buttonYDimen){
            rowCount = self.buttonYDimen
        }
        
        iconImage = UIImage(contentsOfFile: self.iconFd)!
        buttonTotal = self.buttonXDimen * rowCount;
        buttonXMax = self.buttonXOffset + 10 * self.buttonXMultip;
        buttonYMax = self.buttonYOffset + 5 * self.buttonYMultip;
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        getLevels();
    }
    
    required init?(coder aDecoder: NSCoder) {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var fileURL =  url.appendingPathComponent(appName);
        fileURL = fileURL.appendingPathComponent(testFd);
        var rowCount = 0;
        do{
            let contents = try NSString(contentsOfFile : fileURL.path, encoding: String.Encoding.ascii.rawValue)
            var curval = Int(contents as String);
            rowCount = curval! + 1
        } catch{
            print("ERROR: \(error)")
        }
        if(rowCount > self.buttonYDimen){
            rowCount = self.buttonYDimen
        }
        
        iconImage = UIImage(contentsOfFile: self.iconFd)!
        buttonTotal = self.buttonXDimen * rowCount;
        buttonXMax = self.buttonXOffset + 10 * self.buttonXMultip;
        buttonYMax = self.buttonYOffset + 5 * self.buttonYMultip;
        super.init(coder: aDecoder)
        getLevels();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playing = 0
        // Do any additional setup after loading the view.
        for i in 0..<self.buttonTotal{
            let buttonRow = i / self.buttonXDimen;
            let buttonCol = i % self.buttonXDimen;
            let xPosition = self.buttonXOffset + (buttonCol * buttonXMultip)
            let yPosition = self.buttonYOffset + (buttonRow * buttonYMultip)
            let levelButton = UIButton(frame : CGRect(x : xPosition, y : yPosition, width : self.bsidedim, height : self.bsidedim))
            levelButton.layer.cornerRadius = 10
            levelButton.setImage(self.iconImage, for: UIControlState.normal)
            levelButton.setTitle("", for: UIControlState.normal)
            levelButton.addTarget(self, action: #selector(LevelSelectImgController.loadStageArr(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(levelButton);
        }
    }
    func loadStageArr(_ sender: UIButton) {
        var xloc = Int(sender.frame.origin.x)
        var yloc = Int(sender.frame.origin.y)
        
        xloc = (xloc - self.buttonXOffset) / self.buttonXMultip
        yloc = (yloc - self.buttonYOffset) / self.buttonYMultip
        //let str = sender.titleLabel?.text
        //let intString = str?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        level = Int32(xloc + (yloc * self.buttonXDimen))//Int32(intString!)!
        if(level < 0){
            level = Int32(xloc + (yloc * self.buttonXDimen) % self.buttonXDimen)
        }
        performSegue(withIdentifier: "ToGameView", sender: self);
        //print(xloc + (yloc * self.buttonXDimen))
    }
    
    @IBAction func loadStage1(_ sender: UIButton) {
        var xloc = Int(sender.frame.origin.x)
        var yloc = Int(sender.frame.origin.y)
        
        xloc = (xloc - self.buttonXOffset) / self.buttonXMultip
        yloc = (yloc - self.buttonYOffset) / self.buttonYMultip
        //let str = sender.titleLabel?.text
        //let intString = str?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        level = Int32(xloc + (yloc * self.buttonXDimen))//Int32(intString!)!
        if(level < 0){
            level = Int32(xloc + (yloc * self.buttonXDimen) % self.buttonXDimen)
        }
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


