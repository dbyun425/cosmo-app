//
//  LevelSelectImgController.swift
//  gadget_test_2
//
//  Created by Ray Ye on 3/23/18.
//  Copyright © 2018 Peter Lee. All rights reserved.
//

import UIKit


class MechanicTestingController: UIViewController {
    
    let testFd = "testReadWrite.txt";
    let replacementText = "1";
    let initText = "0";
    let appName = "Gadget Game";
    let fm = FileManager.default;
    
    @IBAction func makeFolder(){
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folderURL =  url.appendingPathComponent(appName)
        do {
            try fm.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
        print(folderURL)
    }

    @IBAction func makeTxtFile(){
        print("lel")
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var fileURL =  url.appendingPathComponent(appName);
        fileURL = fileURL.appendingPathComponent(testFd);
        do{
            let attempt = fm.createFile(atPath: fileURL.path, contents: nil, attributes: nil);
            if(attempt){
                print("FILE CREATED")
                print(fileURL)
                try initText.write(toFile: fileURL.path, atomically : true, encoding: .utf8);
            } else {
                print("FILE FAILED")
            }
        } catch {
            print(error);
        }
        
    }
    
    @IBAction func printText(){
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var fileURL =  url.appendingPathComponent(appName);
        fileURL = fileURL.appendingPathComponent(testFd);
        do{
            let contents = try NSString(contentsOfFile : fileURL.path, encoding: String.Encoding.ascii.rawValue)
            print(contents);
        } catch{
            print("ERROR: WRONG TEXT FILE")
        }
    }
    
    @IBAction func replaceText(){
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var fileURL =  url.appendingPathComponent(appName);
        fileURL = fileURL.appendingPathComponent(testFd);
        do{
            let contents = try NSString(contentsOfFile : fileURL.path, encoding: String.Encoding.ascii.rawValue)
            var curval = Int(contents as String);
            curval? += 1
            let newStr = "\(curval!)"
            try newStr.write(toFile: fileURL.path, atomically : true, encoding: .utf8)
        } catch{
            print("ERROR: \(error)")
        }
    }
    
    @IBAction func makeFileInDirectory(){
        return
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playing = 0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func writeToFile(_ sender: UIButton) {
    }
    
    @IBAction func readFromFile(_ sender: UIButton) {
    }
    
    @IBAction func printFile(_ sender: UIButton) {
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
    
}



