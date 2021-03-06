//
//  GameViewController.swift
//  gadget_test_2
//
//  Created by Peter Lee on 6/2/15.
//  Copyright (c) 2015 Peter Lee. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    var semaphore: DispatchSemaphore
    
    @IBOutlet weak var menu: UIButton!
    
    @IBAction func actionBeforeUnwind(_ sender: Any) {
            playing = 0
    }
    
    @IBAction func unwindSegue(unwindSegue:UIStoryboardSegue)
    {
    }
    
    @IBOutlet weak var verticalSlider: UISlider!{
        didSet{
            verticalSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));   }
    }
    
    @IBOutlet weak var verticalProgress: UIProgressView!{
        didSet{
            verticalProgress.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        }
    }
    
    @IBAction func attractOrRepel(_ sender: UISwitch) {
        print("sadgaergeqhrtwhwrthwrthwrthwtrhwtrh")
        interactionFactor *= -1
        print(interactionFactor)
    }
    
    @IBAction func attractToRepel(_ sender: UISlider) {
        print("sadgaergeqhrtwhwrthwrthwrthwtrhwtrh")
        interactionFactor = sender.value
        print(interactionFactor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.semaphore = DispatchSemaphore(value: 0)
        
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // start Gadget on background thread
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        
        queue.async(execute: { () -> Void in
            var input = ""
            switch(level)
            {
            case(1):
                input = "ics_100_32_neg1_a_slice"
                break
            case(2):
                input = "ics_100_32_plus1_a_slice"
                break
            case(3):
                input = "ics_100_64_neg2_a_slice"
                break
            case(4):
                input = "ics_100_64_plus3_a_slice"
                break
            default:
                input = "ics_100_32_zero_a_slice"
                break
                
            }
            gadget_main_setup(strdup(input))
            
            // release semaphore
            self.semaphore.signal()
            gadget_main_run()
            
            // Gadget ended, free memory
            free_memory()
            
            print("gadget end")
        })
        
        // semaphore lock
        let t: Int64 = 10000000000 // wait time in ns
        let timeout = DispatchTime.now() + Double(t) / Double(NSEC_PER_SEC)
        let semaphoreSuccess = self.semaphore.wait(timeout: timeout)
        switch semaphoreSuccess {
        case .timedOut:
            print("error")
            exit(EXIT_FAILURE)
        default:
            ()
        }

        // set up Sprite Kit view
        let scene = GameScene(size: self.view.bounds.size)
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.backgroundColor = UIColor.black
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }
    

    
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.landscape
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
