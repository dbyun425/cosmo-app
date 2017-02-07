


// NOTE: This file is just an archive of different plotting methods tried in
// the progress of creating this program. Proceed on reading only if you intend
// to decipher the many confusing functionalities.




//
//  GameScene.swift
//  gadget_test_2
//
//  Created by Peter Lee on 6/2/15.
//  Copyright (c) 2015 Peter Lee. All rights reserved.
//

//import SpriteKit

//class GameScene: SKScene {
//
//    var points: [SKSpriteNode] // marks the location of particles
//    var borders: [SKShapeNode]
//    var totalParticles: Int
//    var testSprite1: SKSpriteNode // test
//    var testSprite2: SKSpriteNode // test
//    var touchTracker: SKShapeNode // tracks touch location for interaction
//    var accelLabel: SKLabelNode // displays acceleration used for interaction
//    var prevPinchScale: CGFloat = 1.0
//    
//    var xRotateAngle: CGFloat = 15.0 / 360.0 * CGFloat(2 * M_PI) // rad
//    var yRotateAngle: CGFloat = 30.0 / 360.0 * CGFloat(2 * M_PI) // rad
//    
//    var vertices: [(x: CGFloat, y: CGFloat, z: CGFloat)] = [
//        (0.0, 0.0, 0.0),
//        (1.0, 0.0, 0.0),
//        (0.0, 1.0, 0.0),
//        (0.0, 0.0, 1.0),
//        (0.0, 1.0, 1.0),
//        (1.0, 0.0, 1.0),
//        (1.0, 1.0, 0.0),
//        (1.0, 1.0, 1.0)
//    ]
//    var minZ: CGFloat = CGFloat.max
//    var maxZ: CGFloat = CGFloat.min
//    
//    var C: Cuboid
//    var prevCells: [Int]
//    var xShiftOffset: CGFloat
//    var yShiftOffset: CGFloat
//    var zoomScale: CGFloat
//    
//    override init(size: CGSize) {
//        // initialize
//        self.testSprite1 = SKSpriteNode(color: UIColor.magentaColor(), size: CGSizeMake(50.0, 50.0)) // test
//        self.testSprite2 = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(50.0, 50.0)) // test
//        self.points = []
//        self.borders = []
//        self.totalParticles = Int(All.TotNumPart)
//        
//        // initialize cuboid transform parameters
//        self.C = Cuboid(u1: (3, 2, 1), u2: (-1, 1, 2), u3: (1, 1, 1)) // 32 cells
////        self.C = Cuboid(u1: (1, 1, 1), u2: (1, 0, 0), u3: (0, 1, 0)) // 11 cells
//        self.prevCells = [Int](count: self.totalParticles, repeatedValue: 0)
//        
//        // initialize scaling parameters
//        self.xShiftOffset = 0.0
//        self.yShiftOffset = 0.0
//        let widthScale = size.width / CGFloat(self.C.getDimensions().l1)
//        let heightScale = size.height / CGFloat(self.C.getDimensions().l2)
//        self.zoomScale = min(widthScale, heightScale)
//        
//        // initialize particle interaction tracker
//        self.touchTracker = SKShapeNode(circleOfRadius: 20.0)
//        self.touchTracker.fillColor = UIColor.whiteColor()
//        self.touchTracker.strokeColor = UIColor.clearColor()
//        
//        self.accelLabel = SKLabelNode(text: "TESZTETSETSDKVADFBDND")
//        self.accelLabel.color = UIColor.whiteColor()
//        
//        // finalize
//        super.init(size: size)
//        
//        self.testSprite1.position = CGPointMake(self.frame.width / 2.0, self.frame.height / 2.0) // test
//        self.testSprite1.zPosition = CGFloat.infinity // test
//        self.testSprite2.position = CGPointMake(self.frame.width / 2.0, self.frame.height / 2.0) // test
//        self.testSprite2.zPosition = CGFloat.infinity // test
////        self.addChild(self.testSprite1) // test
////        self.addChild(self.testSprite2) // test
//        self.addChild(self.touchTracker)
//        self.accelLabel.position = CGPoint(x: self.frame.width / 2.0, y: self.frame.height - 100.0)
//        self.addChild(self.accelLabel)
//        
//        let pointSize = CGSizeMake(2.0, 2.0)
//        for (var i = 0; i < self.totalParticles; i++) {
//            let thisPoint = SKSpriteNode(color: UIColor.cyanColor(), size: pointSize)
//            self.points.append(thisPoint)
//            self.addChild(thisPoint)
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        
//        // set boundaries for color scale when using cuboid transform
//        var vs = self.vertices.map({ v in self.transform(v, index: 0) })
//        var zs = vs.map({ (x, y, z) -> CGFloat in
//            return z
//        })
//        self.minZ = zs.reduce(CGFloat.max, combine: { (z1, z2) -> CGFloat in
//            return min(z1, z2)
//        })
//        self.maxZ = zs.reduce(CGFloat.min, combine: { (z1, z2) -> CGFloat in
//            return max(z1, z2)
//        })
//        
//        // change border vertices (for rotation)
////        var vertices = map(self.vertices, self.rotate) // transform
////        vertices = map(vertices, { (x, y, z) -> (CGFloat, CGFloat, CGFloat) in
////            return (x + 25.0, y + 150.0, z)
////        }) // fix offset
////        var zs = map(vertices, { (x, y, z) -> CGFloat in
////            return z
////        })
////        self.minZ = reduce(zs, CGFloat.max) { (z1, z2) -> CGFloat in
////            return min(z1, z2)
////        }
////        self.maxZ = reduce(zs, CGFloat.min) { (z1, z2) -> CGFloat in
////            return max(z1, z2)
////        }
//
//        // add borders
////        self.addBorder(start: 0, end: 1)
////        self.addBorder(start: 0, end: 2)
////        self.addBorder(start: 0, end: 3)
////        self.addBorder(start: 1, end: 5)
////        self.addBorder(start: 1, end: 6)
////        self.addBorder(start: 2, end: 4)
////        self.addBorder(start: 2, end: 6)
////        self.addBorder(start: 3, end: 4)
////        self.addBorder(start: 3, end: 5)
////        self.addBorder(start: 4, end: 7)
////        self.addBorder(start: 5, end: 7)
////        self.addBorder(start: 6, end: 7)
//        
//        // add gesture recognizers
////        let panGesture = UIPanGestureRecognizer()
////        panGesture.addTarget(self, action: "panned:")
////        self.view?.addGestureRecognizer(panGesture)
//        
//        let pinchGesture = UIPinchGestureRecognizer()
//        pinchGesture.addTarget(self, action: "pinched:")
//        self.view?.addGestureRecognizer(pinchGesture)
//        
//        let shiftGesture = UIPanGestureRecognizer()
//        shiftGesture.minimumNumberOfTouches = 2
//        shiftGesture.addTarget(self, action: "shifted:")
//        self.view?.addGestureRecognizer(shiftGesture)
//
//    }
//    
//    // handles pann gestures
//    // changes rotation angles
//    func panned(sender: UIPanGestureRecognizer) {
//        
//        // get pan directions
//        let vel : CGPoint = sender.velocityInView(self.view)
//        let velX = vel.x
//        let velY = vel.y
//        
//        // get original positions
//        let pos1 = self.testSprite1.position
//        let pos2 = self.testSprite2.position
//        var (pos1x, pos1y) = (pos1.x, pos1.y)
//        var (pos2x, pos2y) = (pos2.x, pos2.y)
//        
//        let panScale: CGFloat = 10.0
//        if (abs(velX) > 20.0) { // to ignore small movements
//            let newPos2 = CGPointMake(pos2x + velX / panScale, pos2y)
//            self.testSprite2.position = newPos2
//            
//            if (velX < 0.0) {
//                self.yRotateAngle -= 0.1 // note: panning in x direction changes y rotation angle (and vice versa)
//            }
//            else { // velX >= 0.0
//                self.yRotateAngle += 0.1
//            }
//        }
//        
//        if (abs(velY) > 20.0) { // to ignore small movements
//            // UIView coordinates (?) with +y pointing downwards (much confuse)
//            // hence the "-"
//            let newPos1 = CGPointMake(pos1x, pos1y - velY / panScale)
//            self.testSprite1.position = newPos1
//            
//            if (velY < 0.0) {
//                self.xRotateAngle -= 0.1
//            }
//            else { // velY >= 0.0
//                self.xRotateAngle += 0.1
//            }
//        }
//        
//    }
//    
//    // handles pinch gesture
//    func pinched(sender: UIPinchGestureRecognizer) {
//        // get original size
//        let size1 = self.testSprite1.size
//        let size2 = self.testSprite2.size
//        
//        // set scale and transform
//        let pinchScale = sender.scale
//        sender.scale = 1
//        
//        let newSize1 = CGSizeMake(size1.width * pinchScale, size1.height * pinchScale)
//        let newSize2 = CGSizeMake(size2.width * pinchScale, size2.height * pinchScale)
//        
//        self.testSprite1.size = newSize1
//        self.testSprite2.size = newSize2
//        
//        if (sender.state == UIGestureRecognizerState.Ended) {
//            self.prevPinchScale = 1.0
//        }
//        
//        // modify scale value
//        self.zoomScale *= pinchScale
//    }
//    
//    // handles shift gesture
//    func shifted(sender: UIPanGestureRecognizer) {
//        // get original positions
//        let pos1 = self.testSprite1.position
//        let pos2 = self.testSprite2.position
//        let (pos1x, pos1y) = (pos1.x, pos1.y)
//        let (pos2x, pos2y) = (pos2.x, pos2.y)
//        
//        // get shift direction
//        let vel = sender.velocityInView(self.view)
//        let shiftScale: CGFloat = 10.0
//        let (velX, velY) = (vel.x / shiftScale, vel.y / shiftScale)
//        
//        // new positions (again with flipped UIView y-coordinate
//        let newPos1 = CGPointMake(pos1x + velX, pos1y - velY)
//        let newPos2 = CGPointMake(pos2x + velX, pos2y - velY)
//        
//        self.testSprite1.position = newPos1
//        self.testSprite2.position = newPos2
//        
//        // modify shift value
//        // note that UIView y-coordinates are opposite from Sprite Kit
//        self.xShiftOffset += velX
//        self.yShiftOffset -= velY
//    }
//    
//    // adds border to the bounding box with specified start and end vertex numbers
//    func addBorder(start _start: Int, end _end: Int) -> Void {
//        let path = self.getPath(start: _start, end: _end)
//        let border = SKShapeNode(path: path)
//        border.strokeColor = UIColor.greenColor()
//        
//        self.borders.append(border)
//        self.addChild(border)
//    }
//
//    // finds the path of the border specified by start and end vertex numbers
//    func getPath(start _start: Int, end _end: Int) -> CGPath {
//        
//        // update corner vertices
//        var vertices : [(x: CGFloat, y: CGFloat, z: CGFloat)] = self.vertices.map(self.rotate) // transform
//        vertices = vertices.map({ (x, y, z) -> (x: CGFloat, y: CGFloat, z: CGFloat) in
//            return (x + 25.0, y + 150.0, z)
//        }) // fix offset
//        
//        let path = CGPathCreateMutable()
//        CGPathMoveToPoint(path, nil, vertices[_start].x, vertices[_start].y)
//        CGPathAddLineToPoint(path, nil, vertices[_end].x, vertices[_end].z)
//        
//        return path
//    }
//    
//    // find the new path each frame for the borders after rotation
//    func updatePath() -> Void {
//        self.borders[0].path = getPath(start: 0, end: 1)
//        self.borders[1].path = getPath(start: 0, end: 2)
//        self.borders[2].path = getPath(start: 0, end: 3)
//        self.borders[3].path = getPath(start: 1, end: 5)
//        self.borders[4].path = getPath(start: 1, end: 6)
//        self.borders[5].path = getPath(start: 2, end: 4)
//        self.borders[6].path = getPath(start: 2, end: 6)
//        self.borders[7].path = getPath(start: 3, end: 4)
//        self.borders[8].path = getPath(start: 3, end: 5)
//        self.borders[9].path = getPath(start: 4, end: 7)
//        self.borders[10].path = getPath(start: 5, end: 7)
//        self.borders[11].path = getPath(start: 6, end: 7)
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        /* Called when a touch begins */
//        
//        if (touches.count == 1) {
//            // start particle interaction
////            println("touches began")
//            interaction = 1
//            self.updateTouchLocation(touches)
//        }
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if (touches.count == 1) {
//            // update touch location for particle interaction
////            println("touches moved, interaction: \(interaction)")
//            self.updateTouchLocation(touches)
//        }
//    }
//    
//    func updateTouchLocation(touches: Set<NSObject>) {
//        // inverse transfrom the touch location to the actual simulation
//        // coordinates and update them
//        if (touches.count < 1) {
//            return
//        }
//        
//        let touch: UITouch = touches.first as! UITouch
//        let location = touch.locationInNode(self)
//        
//        let x = location.x
//        let y = location.y
//        let z = (self.minZ + self.maxZ) / 2.0
//        
//        let result = self.inverseTransform((x, y, z))
//        
//        touchLocation.0 = Float(result.0)
//        touchLocation.1 = Float(result.1)
//        touchLocation.2 = Float(result.2)
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        // stop particle interaction
////        println("touches ended")
//        interaction = 0;
//    }
//   
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//        
//        // set positions
//        // MARK: MAKE SURE THAT THE IDIOT WHO INDEXED ARRAYS STARTING FROM 1
//        //       KNOWS WHAT HE'S DOING
//        for (var i = 0; i < self.totalParticles; i++) {
//            var (xPos1, yPos1, zPos1) = P[i + 1].Pos // retrieve particle position from all particle data // <---- THIS PART
//            var xPos = CGFloat(xPos1)
//            var yPos = CGFloat(yPos1)
//            var zPos = CGFloat(zPos1)
//            
//            // rotation tests
////            (xPos, yPos, zPos) = rotate((xPos, yPos, zPos))
////            xPos += 25.0
////            yPos += 150.0
//            
//            // transformation test
//            (xPos, yPos, zPos) = self.transform((xPos, yPos, zPos), index: i)
//            
//            let thisPoint = self.points[i]
//            thisPoint.position = CGPointMake(xPos, yPos)
//            thisPoint.zPosition = zPos
//            self.setColor(thisPoint)
//        }
//
//        // update borders
////        self.updatePath()
//        
//        // update touch tracker for particle interactions
//        if (interaction == 0) {
//            self.touchTracker.fillColor = UIColor.clearColor()
//        }
//        else {
//            self.touchTracker.fillColor = UIColor.whiteColor()
//            let touchX = CGFloat(touchLocation.0)
//            let touchY = CGFloat(touchLocation.1)
//            let touchZ = CGFloat(touchLocation.2)
//            let trackerLocation = self.transform((touchX, touchY, touchZ), index: 0)
//            self.touchTracker.position = CGPointMake(trackerLocation.0, trackerLocation.1)
//        }
//        
//        // update acceleration label
//        self.accelLabel.text = "\(accelerationFactor)"
//    }
//    
//    // cuboid tranform wrapper function
//    func transform(pos: (x: CGFloat, y: CGFloat, z: CGFloat), index i: Int) -> (CGFloat, CGFloat, CGFloat) {
//        // change into coordinates in the unit cube
//        let x = Double(pos.x) / All.BoxSize
//        let y = Double(pos.y) / All.BoxSize
//        let z = Double(pos.z) / All.BoxSize
//        
//        // transform
//        let prevCellIdx = self.prevCells[i]
//        let result = C.transform(x: x, y: y, z: z, prevCell: prevCellIdx)
//        self.prevCells[i] = result.cell
//        
//        // test scaling and shifting
//        var x1 = CGFloat(result.pos.x) * self.zoomScale
//        var y1 = CGFloat(result.pos.y) * self.zoomScale
//        let z1 = CGFloat(result.pos.z) * self.zoomScale
//        x1 += self.xShiftOffset
//        y1 += self.yShiftOffset
//        
//        return (x1, y1, z1)
//    }
//    
//    // cuboid inverse transform wrapper function
//    func inverseTransform(pos: (x: CGFloat, y: CGFloat, z: CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
//        // undo scaling and shifting
//        let scale = Double(self.zoomScale)
//        var x1 = Double(pos.x - self.xShiftOffset)
//        var y1 = Double(pos.y - self.yShiftOffset)
//        var z1 = Double(pos.z)
//        x1 /= scale
//        y1 /= scale
//        z1 /= scale
//        
//        let result: (x: Double, y: Double, z: Double) = C.inverseTransform(x: x1, y: y1, z: z1)
//        
//        let x2 = CGFloat(result.x * All.BoxSize)
//        let y2 = CGFloat(result.y * All.BoxSize)
//        let z2 = CGFloat(result.z * All.BoxSize)
//        
//        return (x2, y2, z2)
//    }
//    
//    // rotation test functions
//    
//    func rotate(pos: (CGFloat, CGFloat, CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
//        // rotations wrapper
//        return self.rotateX(self.rotateY(pos))
//        // return self.rotateX(self.rotateY(self.rotateZ(pos)))
//    }
//    
//    // rotation around x axis
//    // angle defined by self.xRotateAngle
//    func rotateX(pos: (CGFloat, CGFloat, CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
//        let (x, y, z) = pos
//        let t = self.xRotateAngle
////        var x1 = x
////        var y1 = (y * (1.0 + sqrt(3.0)) - z * (-1.0 + sqrt(3.0)))
////        var z1 = (y * (-1.0 + sqrt(3.0)) + z * (1.0 + sqrt(3.0)))
////        
////        var normalizeScale = CGFloat(2.0 * sqrt(2.0))
////        y1 /= normalizeScale
////        z1 /= normalizeScale
//        
//        let x1 = x
//        let y1 = y * cos(t) + z * (-sin(t))
//        let z1 = y * sin(t) + z * cos(t)
//        
//        return (x1, y1, z1)
//    }
//    
//    // rotation around y axis
//    // angle defined by self.yRotateAngle
//    func rotateY(pos: (CGFloat, CGFloat, CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
//        let (x, y, z) = pos
//        let t = self.yRotateAngle
//        
////        var x1 = x * sqrt(3.0) / 2.0 + z / 2.0
////        var y1 = y
////        var z1 = z * sqrt(3.0) / 2.0 - x / 2.0
//        
//        let x1 = x * cos(t) + z * sin(t)
//        let y1 = y
//        let z1 = x * (-sin(t)) + z * cos(t)
//        
//        return (x1, y1, z1)
//    
//    }
//    
//    // 45 degrees rotation around z axis
//    func rotateZ(pos: (CGFloat, CGFloat, CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
//        let (x, y, z) = pos
//        let x1 = x / sqrt(2.0) - y / sqrt(2.0)
//        let y1 = x / sqrt(2.0) + y / sqrt(2.0)
//        let z1 = z
//        
//        return (x1, y1, z1)
//    }
//    
//    func setColor(node: SKSpriteNode) {
//        let zPos = node.zPosition
////        let greenScale = (zPos / CGFloat(All.BoxSize / 100.0))
//        let greenScale = self.getGreenScale(zPos) // temp greenScale for with rotation transform
////        let color = UIColor.cyanColor().colorWithAlphaComponent(greenScale)
//       let color = UIColor(red: 0.0, green: greenScale, blue: 1.0, alpha: 1.0)
//        
//        node.color = color
//    }
//    
//    // temp getGreenScale for with rotations
//    func getGreenScale(zPos: CGFloat) -> CGFloat {
//        let minZ = self.minZ
//        let maxZ = self.maxZ
//        
//        return (zPos - minZ) / (maxZ - minZ)
//    }
//    
//}
