//
//  GameScene.swift
//  gadget_test_2
//
//  Created by Peter Lee on 9/20/15.
//  Copyright © 2015 Peter Lee. All rights reserved.
//
//  Modifications: adding colors and a chaining mesh
//  chaining mesh is used as a friend of friends to find galaxies clustered together
//  cuboid representation removed since it no longer needed when examining a slice
//

import Foundation
import SpriteKit
import AVFoundation

var audioPlayer: AVAudioPlayer!

let path = Bundle.main.path(forResource: "Sounds/254031__jagadamba__space-sound", ofType:"wav")!
let url = URL(fileURLWithPath: path)

var musicPlayer: AVAudioPlayer!
let musicPath = Bundle.main.path(forResource: "Sounds/DST-PhaserSwitch", ofType:"mp3")!
let musicUrl = URL(fileURLWithPath: musicPath)
var initTime = Date().timeIntervalSinceReferenceDate

class GameScene: SKScene {
    
    var points: [SKSpriteNode] // marks the location of particles
    var galaxySprite: [SKSpriteNode]
    var galaxySizes: [CGSize]
    var totalParticles: Int
    
    var equivClass: [(Int,Bool)] // will be used for equivalence class and galaxy pairings
    var equivCount: [Int]
    
    var timeCounter: Int
    var touchTracker: SKShapeNode // tracks touch location for interaction
    var accelLabel: SKLabelNode // displays acceleration used for interaction
    var galaxyCounter: SKLabelNode // displays the number of galaxies
    var prevPinchScale: CGFloat = 1.0
    
    var chainMesh: [[[Int]]]
    var cellSize: Int = 500

    //colors were retrieved from the following website http://cloford.com/resources/colours/500col.htm
    var classColors: [UIColor] = [
        UIColor(red: 255.0/255.0, green: 215.0/255.0, blue: 0.0, alpha: 1.0), //gold1
        UIColor(red: 124.0/255.0, green: 205.0/255.0, blue: 124.0/255.0, alpha: 1.0), //palegreen3
        UIColor(red: 0.0, green: 197.0/255.0, blue: 205.0/255.0, alpha: 1.0), //turquoise3
        UIColor(red: 132.0/255.0, green: 112.0/255.0, blue: 255.0/255.0, alpha: 1.0), //lightslateblue
        UIColor(red: 255.0/255.0, green: 130.0/255.0, blue: 171.0/255.0, alpha: 1.0), //palevioletred1
        UIColor(red: 255.0/255.0, green: 114.0/255.0, blue: 86.0/255.0, alpha: 1.0)] //coral1
    
        var vertices: [(x: CGFloat, y: CGFloat, z: CGFloat)] = [
            (0.0, 0.0, 0.0),
            (1.0, 0.0, 0.0),
            (0.0, 1.0, 0.0),
            (0.0, 0.0, 1.0),
            (0.0, 1.0, 1.0),
            (1.0, 0.0, 1.0),
            (1.0, 1.0, 0.0),
            (1.0, 1.0, 1.0)
        ]
    
    var minZ: CGFloat = CGFloat.greatestFiniteMagnitude
    var maxZ: CGFloat = CGFloat.leastNormalMagnitude
    
    //var C: Cuboid
    //var prevCells: [Int] // cache of cells indices for faster access
    var xShiftOffset: CGFloat
    var yShiftOffset: CGFloat
    var zoomScale: CGFloat
    
    override init(size: CGSize) {
        let sound = try! AVAudioPlayer(contentsOf: url)
        audioPlayer = sound
        let music = try! AVAudioPlayer(contentsOf: musicUrl)
        musicPlayer = music
        music.play();
        music.numberOfLoops = -1
        clusterLevel = 0;
        // initialize
        self.points = []
        self.galaxySprite = []
        self.galaxySizes = []
        self.totalParticles = Int(All.TotNumPart)
        initTime = Date().timeIntervalSinceReferenceDate
        // initialize cuboid transform parameters (choose one)
        //self.C = Cuboid(u1: (1,0,0), u2: (0,1,0), u3: (0,0,1))
        //self.C = Cuboid(u1: (3, 2, 1), u2: (-1, 1, 2), u3: (1, 1, 1)) // 32 cells
        //        self.C = Cuboid(u1: (1, 1, 1), u2: (1, 0, 0), u3: (0, 1, 0)) // 11 cells
        //self.prevCells = [Int](count: self.totalParticles, repeatedValue: 0)
        self.equivClass = [(Int,Bool)](repeating: (0,false), count: self.totalParticles+1)
        self.equivCount = [Int](repeating: 1, count: self.totalParticles+1)
        for i in 0 ..< self.totalParticles {
            self.equivClass[i+1] = (i + 1,false)
        }
        P[1].Vel=(0,0,0)
        P[1].VelPred=(0,0,0);
        self.timeCounter = 0
        
        // initialize scaling parameters
        self.xShiftOffset = 200.0
        self.yShiftOffset = 0.0
        let widthScale = size.width // / CGFloat(self.C.getDimensions().l1)
        let heightScale = size.height // / CGFloat(self.C.getDimensions().l2)
        self.zoomScale = min(widthScale, heightScale)
        
        // initialize particle interaction tracker
        self.touchTracker = SKShapeNode(circleOfRadius: 20.0)
        self.touchTracker.fillColor = UIColor.white
        self.touchTracker.strokeColor = UIColor.clear
        
        self.accelLabel = SKLabelNode(text: "TESZTETSETSDKVADFBDND")
        self.accelLabel.color = UIColor.white
        
        self.galaxyCounter = SKLabelNode(text: "NUMBER OF GALAXIES:")
        self.galaxyCounter.color = UIColor.white
        
        self.chainMesh = [[[Int]]](repeating: [[Int]](repeating: [Int](), count: Int(All.BoxSize)/self.cellSize), count: Int(All.BoxSize)/self.cellSize)
        
        // finalize
        super.init(size: size)
        
        //add touch tracker
        self.addChild(self.touchTracker)
        self.accelLabel.position = CGPoint(x: self.frame.width / 2.0, y: self.frame.height - 100.0)
        self.galaxyCounter.position = CGPoint(x: self.frame.width - 70.0 , y: self.frame.height - 100.0)
        self.addChild(self.accelLabel)
        self.addChild(self.galaxyCounter)
        
        //add points and galaxy
        let pointSize = CGSize(width: 2.0, height: 2.0)
        let galaxySize = CGSize(width: 60.0, height: 50.0)
        let gSize2 = CGSize(width: 120.0, height: 100.0)
        let gSize3 = CGSize(width: 180.0, height: 150.0)
        let gSize4 = CGSize(width: 240.0, height: 200.0)
        let gSize5 = CGSize(width: 300.0, height: 250.0)
        let gSize6 = CGSize(width: 360.0, height: 300.0)
        galaxySizes = [galaxySize,gSize2,gSize3,gSize4,gSize5,gSize6]
        for _ in 0 ..< self.totalParticles {
            let thisPoint = SKSpriteNode(color: UIColor.cyan, size: pointSize)
            self.points.append(thisPoint)
            self.addChild(thisPoint)
            let thisGalaxy = SKSpriteNode(imageNamed: "galaxytest.png")
            thisGalaxy.size = galaxySize
            self.galaxySprite.append(thisGalaxy)
            self.addChild(thisGalaxy)
            thisGalaxy.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        // set boundaries for color scale when using cuboid transform
        let vs = self.vertices.map({ v in self.transform(v, index: 0) })
        let zs = vs.map({ (x, y, z) -> CGFloat in
            return z
        })
        self.minZ = zs.reduce(CGFloat.greatestFiniteMagnitude, { (z1, z2) -> CGFloat in
            return min(z1, z2)
        })
        self.maxZ = zs.reduce(CGFloat.leastNormalMagnitude, { (z1, z2) -> CGFloat in
            return max(z1, z2)
        })
        
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(GameScene.pinched(_:)))
        self.view?.addGestureRecognizer(pinchGesture)
        
        let shiftGesture = UIPanGestureRecognizer()
        shiftGesture.minimumNumberOfTouches = 2
        shiftGesture.addTarget(self, action: #selector(GameScene.shifted(_:)))
        self.view?.addGestureRecognizer(shiftGesture)
        
    }
    
    // handles pinch gesture
    func pinched(_ sender: UIPinchGestureRecognizer) {
        /*
        // set scale and transform
        let pinchScale = sender.scale
        sender.scale = 1
        
        if (sender.state == UIGestureRecognizerState.Ended) {
            self.prevPinchScale = 1.0
        }
        
        // modify scale value
        self.zoomScale *= pinchScale */
    }
    
    // handles shift gesture
    func shifted(_ sender: UIPanGestureRecognizer) {
        /*
        // get shift direction
        let vel = sender.velocityInView(self.view)
        let shiftScale: CGFloat = 10.0
        let (velX, velY) = (vel.x / shiftScale, vel.y / shiftScale)
        
        // modify shift value
        // note that UIView y-coordinates are opposite from Sprite Kit
        self.xShiftOffset += velX
        self.yShiftOffset -= velY */
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if (touches.count == 1) {
            // start particle interaction
            //            println("touches began")
            interaction = 1
            accelerationFactor = 1000000.0 * interactionFactor;
            P[1].Mass = accelerationFactor;
            self.updateTouchLocation(touches)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touches.count == 1) {
            // update touch location for particle interaction
            //            println("touches moved, interaction: \(interaction)")
            //interaction = 0
            self.updateTouchLocation(touches)
            //interaction = 1
        }
    }
    
    func updateTouchLocation(_ touches: Set<NSObject>) {
        // inverse transfrom the touch location to the actual simulation
        // coordinates and update them
        if (touches.count < 1) {
            return
        }
        
        let touch: UITouch = touches.first as! UITouch
        let location = touch.location(in: self)
        
        let x = location.x
        let y = location.y
        let z = CGFloat(0) //(self.minZ + self.maxZ) / 2.0
        
        let result = self.inverseTransform((x, y, z))
        
        touchLocation.0 = Float(result.0)
        touchLocation.1 = Float(result.1)
        touchLocation.2 = Float(result.2)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // stop particle interaction
        //        println("touches ended")
        interaction = 0;
        P[1].Mass = 0;
        P[1].Vel=(0,0,0);
        P[1].VelPred=(0,0,0);
        P[1].Accel = (0,0,0);
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if(playing == 0){
            return;         //The return statement that saved us all. You can safely go back to the menu now.
        }
        if(gamePause == 0) {
        
        // set positions
        // MARK: MAKE SURE THAT THE IDIOT WHO INDEXED ARRAYS STARTING FROM 1
        //       KNOWS WHAT HE'S DOING
        scoreCounter = 0
        for i in 0 ..< self.totalParticles {
            let (xPos1, yPos1, zPos1) = P[i + 1].Pos // retrieve particle position from all particle data // <---- THIS PART
            var xPos = CGFloat(xPos1)
            var yPos = CGFloat(yPos1)
            var zPos = CGFloat(zPos1)
            
            // transformation
            (xPos, yPos, zPos) = self.transform((xPos, yPos, zPos), index: i)
            
            let thisPoint = self.points[i]
            let thisGalaxy = self.galaxySprite[i]
            thisPoint.position = CGPoint(x: xPos, y: yPos)
            thisPoint.zPosition = zPos
            self.setColor(thisPoint, i: i + 1, thisGalaxy)
        }
        
        //if (self.timeCounter == 100) {
            for n in 0..<self.totalParticles {
                let (x,y,_) = P[n+1].Pos
                self.chainMesh[(Int(x)%Int(All.BoxSize))/self.cellSize][(Int(y)%Int(All.BoxSize))/self.cellSize].append(n+1)
                self.equivClass[n+1] = (n+1,false)
                self.equivCount[n+1] = 1
            }
            union_find()
        //    self.timeCounter = 0
            
            for y in 0 ..< self.chainMesh.count {
                for z in 0 ..< self.chainMesh.count {
                    self.chainMesh[y][z] = [Int]();
                }
            }
        //}
        //self.timeCounter += 1
        
        // update touch tracker for particle interactions
        if (interaction == 0) {
            self.touchTracker.fillColor = UIColor.clear
        }
        else {
            self.touchTracker.fillColor = UIColor.white
            let touchX = CGFloat(touchLocation.0)
            let touchY = CGFloat(touchLocation.1)
            let touchZ = CGFloat(touchLocation.2)
            let trackerLocation = self.transform((touchX, touchY, touchZ), index: 0)
            self.touchTracker.position = CGPoint(x: trackerLocation.0, y: trackerLocation.1)
        }
        
        // update acceleration label
        self.accelLabel.text = "\((Int)(Date().timeIntervalSinceReferenceDate-initTime))"
        self.galaxyCounter.text = "\(scoreCounter)"
        }
    }
    
    // cuboid tranform wrapper function
    func transform(_ pos: (x: CGFloat, y: CGFloat, z: CGFloat), index i: Int) -> (CGFloat, CGFloat, CGFloat) {
        // change into coordinates in the unit cube
        let x = Double(pos.x) / All.BoxSize
        let y = Double(pos.y) / All.BoxSize
        let z = Double(pos.z) / All.BoxSize
        
        // transform
        //let prevCellIdx = self.prevCells[i]
        //let result = C.transform(x: x, y: y, z: z, prevCell: prevCellIdx)
        //self.prevCells[i] = result.cell
        
        // test scaling and shifting
        var x1 = CGFloat(x) * self.zoomScale //CGFloat(result.pos.x) * self.zoomScale
        var y1 = CGFloat(y) * self.zoomScale //CGFloat(result.pos.y) * self.zoomScale
        let z1 = CGFloat(z) * self.zoomScale //CGFloat(result.pos.z) * self.zoomScale
        x1 += self.xShiftOffset
        y1 += self.yShiftOffset
        
        return (x1, y1, z1)
    }
    
    // cuboid inverse transform wrapper function
    func inverseTransform(_ pos: (x: CGFloat, y: CGFloat, z: CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
        // undo scaling and shifting
        let scale = Double(self.zoomScale)
        var x1 = Double(pos.x - self.xShiftOffset)
        var y1 = Double(pos.y - self.yShiftOffset)
        var z1 = Double(pos.z)
        x1 /= scale
        y1 /= scale
        z1 /= scale
        
        //let result: (x: Double, y: Double, z: Double) = C.inverseTransform(x: x1, y: y1, z: z1)
        
        let x2 = CGFloat(x1 * All.BoxSize) //CGFloat(result.x * All.BoxSize)
        let y2 = CGFloat(y1 * All.BoxSize) //CGFloat(result.y * All.BoxSize)
        let z2 = CGFloat(z1 * All.BoxSize) //CGFloat(result.z * All.BoxSize)
        
        return (x2, y2, z2)
    }
    
    func union_find() {
        let range = Float(10000000)
        var dist = Float(0)
        
        //if two particles are within certain distance of each other
        //they are counted as an equivalence class
        for i in 0 ..< self.totalParticles {
            let (x0,y0,_) = P[i + 1].Pos
            let (xIndex,yIndex) = ((Int(x0)%Int(All.BoxSize))/self.cellSize,(Int(y0)%Int(All.BoxSize))/self.cellSize)
            let (equivNum1,_) = self.equivClass[i+1]
            
            for n in -1 ... 1 {
                
                if(xIndex + n >= 0 && xIndex + n < self.chainMesh.count) {
                    
                    for m in -1 ... 1 {
                        
                        if(yIndex + m >= 0 && yIndex + m < self.chainMesh.count) {
                            
                            var temp = self.chainMesh[xIndex+n][yIndex+m];
                            for k in 0..<temp.count {
                                let info = temp[k]
                                let (x1,y1,_) = P[info].Pos
                                let (equivNum2,_) = self.equivClass[info]
                                dist = sqrt((x0-x1)*(x0-x1) + (y0-y1)*(y0-y1)) // Why does the distance become zero??
                                if ((range - dist) >= 0.0) {
                                    self.equivClass[info] = (min(equivNum1,equivNum2),true)
                                }
                            }
                        }
                    }
                }
            }
 
            /*
            for j in (i + 1) ..< self.totalParticles {
                let (x1,y1,_) = P[j + 1].Pos
                let (equivNum2,_) = self.equivClass[j+1]
                
                dist = sqrt((x0-x1)*(x0-x1) + (y0-y1)*(y0-y1))
                
                if ((range - dist) >= 0.0) {
                    self.equivClass[j+1] = (min(equivNum1,equivNum2),true)
                }
            } */
        }
        
        for j in 0 ..< self.totalParticles {
            let (eqNum,_) = self.equivClass[j+1]
            self.equivCount[eqNum] += 1
        }
        
        
    }
    
    //Set color of particles according to number of particles in group,
    //as opposed to INDEX OF PARTICLES LIKE SOME OTHER GUY DID - Doyee
    func setColor(_ node: SKSpriteNode, i: Int, _ galaxy: SKSpriteNode) {
        let (equivNum,classBool) = self.equivClass[i]
        let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        if (i == 1) {
            node.color = black
        }
        else if (classBool && self.equivCount[equivNum] >= 15 && self.equivCount[equivNum] < 30) {
            if (equivNum == i)
            {
                galaxy.position = node.position
                galaxy.zPosition = node.zPosition + 1.0
                galaxy.size = galaxySizes[0]
                galaxy.isHidden = false
            }
            else{
                galaxy.isHidden = true
            }
            //node.color = self.classColors[3]
            node.color = black
            scoreCounter = scoreCounter + 1
            if (clusterLevel < 1)
            {
                clusterLevel = 1;
                audioPlayer.play();
            }
        }
        else if (classBool && self.equivCount[equivNum] >= 30 && self.equivCount[equivNum] < 60) {
            if (equivNum == i)
            {
                galaxy.position = node.position
                galaxy.zPosition = node.zPosition + 1.0
                galaxy.size = galaxySizes[1]
                galaxy.isHidden = false
            }
            else{
                galaxy.isHidden = true
            }
            //node.color = self.classColors[2]
            node.color = black
            scoreCounter = scoreCounter + 2
            if (clusterLevel < 2)
            {
                clusterLevel = 2;
                audioPlayer.play();
            }
        }
        else if (classBool && self.equivCount[equivNum] >= 60 && self.equivCount[equivNum] < 100) {
            if (equivNum == i)
            {
                galaxy.position = node.position
                galaxy.zPosition = node.zPosition + 1.0
                galaxy.size = galaxySizes[2]
                galaxy.isHidden = false
            }
            else{
                galaxy.isHidden = true
            }
            //node.color = self.classColors[1]
            node.color = black
            scoreCounter = scoreCounter + 3
            if (clusterLevel < 3)
            {
                clusterLevel = 3;
                audioPlayer.play();
            }
        }
        else if (classBool && self.equivCount[equivNum] >= 100 && self.equivCount[equivNum] < 150) {
            if (equivNum == i)
            {
                galaxy.position = node.position
                galaxy.zPosition = node.zPosition + 1.0
                galaxy.size = galaxySizes[3]
                galaxy.isHidden = false
            }
            else{
                galaxy.isHidden = true
            }
            //node.color = self.classColors[0]
            node.color = black
            scoreCounter = scoreCounter + 4
            if (clusterLevel < 4)
            {
                clusterLevel = 4;
                audioPlayer.play();
            }
        }
        else if (classBool && self.equivCount[equivNum] >= 150 && self.equivCount[equivNum] < 250) {
            if (equivNum == i)
            {
                galaxy.position = node.position
                galaxy.zPosition = node.zPosition + 1.0
                galaxy.size = galaxySizes[4]
                galaxy.isHidden = false
            }
            else{
                galaxy.isHidden = true
            }
            //node.color = self.classColors[4]
            node.color = black
            scoreCounter = scoreCounter + 5
            if (clusterLevel < 5)
            {
                clusterLevel = 5;
                audioPlayer.play();
            }
        }
        else if (classBool && self.equivCount[equivNum] >= 250) {
            if (equivNum == i)
            {
                galaxy.position = node.position
                galaxy.zPosition = node.zPosition + 1.0
                galaxy.size = galaxySizes[5]
                galaxy.isHidden = false
            }
            else{
                galaxy.isHidden = true
            }
            //node.color = self.classColors[5]
            node.color = black
            scoreCounter = scoreCounter + 6
            if (clusterLevel < 6)
            {
                clusterLevel = 6;
                audioPlayer.play();
            }
        }
        else {
            node.color = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
            galaxy.isHidden = true
        }
    }
    
}
