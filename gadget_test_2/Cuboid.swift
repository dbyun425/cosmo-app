//
//  Cuboid.swift
//  gadget_test_2
//
//  Created by Peter Lee on 6/11/15.
//  Copyright (c) 2015 Peter Lee. All rights reserved.
//
//  A Swift Implementation of a cuboid remapping method by J. Carson and
//  M. White, University of California, Berkeley (2010).
// 
//  original code available at:
//  http://mwhite.berkeley.edu/BoxRemap/
//
//  Minor changes made by Doyee Byun on 1/27/17 to match updated Swift syntax.

import Foundation

// a structure for representing a plane in 3-dimensional space
struct Plane: CustomStringConvertible {
    // a plane defined by ax + by + cz + d = 0
    var a, b, c, d: Double
    
    init() {
        self.a = 0.0
        self.b = 0.0
        self.c = 0.0
        self.d = 0.0
    }
    
    // initialize plane with a point and a normal vector
    init(point: Vec3d, normal: Vec3d) {
        (self.a, self.b, self.c) = normal.tuple()
        self.d = -Vector.dot(point, normal)
    }
    
    // tests if a point (x, y, z) is on the plane
    func test(x _x: Double, y _y: Double, z _z: Double) -> Double {
        return self.a * _x + self.b * _y + self.c * _z + self.d
    }
    
    var description: String {
        return "(a = \(self.a), b = \(self.b), c = \(self.c), d = \(self.d))"
    }
}

struct Cell {
    var ix, iy, iz: Int
    var nfaces: Int
    var face: [Plane]
    
    init() {
        self.init(ix: 0, iy: 0, iz: 0)
    }
    
    init(ix: Int, iy: Int, iz: Int) {
        self.ix = ix
        self.iy = iy
        self.iz = iz
        
        self.nfaces = 0
        self.face = []
    }
    
    // checks if a given point is contained inside the cell
    func contains(x _x: Double, y _y: Double, z _z: Double) -> Bool {
        var b: Bool = true
        
        for i in 0 ..< self.nfaces {
            b = b && (face[i].test(x: _x, y: _y, z: _z) >= 0)
        }
        
        return b
    }
}

// operations required on types used in vectors
protocol Number {
    static func +(n1: Self, n2: Self) -> Self
    static func -(n1: Self, n2: Self) -> Self
    static func *(n1: Self, n2: Self) -> Self
    prefix static func -(n: Self) -> Self
}

// extend Double and Int types to conform to Number protocol
extension Double: Number {}
extension Int: Number {}

// a 3 dimensional vector type
class Vector<T: Number>: CustomStringConvertible {
    var x, y, z: T
    
    init(x: T, y: T, z: T) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    // returns the vector as a tuple
    func tuple() -> (T, T, T) {
        return (self.x, self.y, self.z)
    }
    
    // finds the magnitude squared of a vector
    class func mag2(_ v: Vector<T>) -> T {
        return v.x * v.x + v.y * v.y + v.z * v.z
    }
    
    // takes the dot product of two vectors
    class func dot(_ v1: Vector<T>, _ v2: Vector<T>) -> T {
        return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z)
    }
    
    // takes the cross product of two vectors
    class func cross(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
        let x = v1.y * v2.z - v1.z * v2.y
        let y = v1.z * v2.x - v1.x * v2.z
        let z = v1.x * v2.y - v1.y * v2.x
        return Vector<T>(x: x, y: y, z: z)
    }
    
    // computes the triple scalar product of v1, v2, v3
    class func tripleScalarProduct(v1 _v1: Vector<T>, v2 _v2: Vector<T>, v3 _v3: Vector<T>) -> T {
        return Vector.dot(_v1, Vector.cross(_v2, _v3))
    }
    
    var description: String {
        return "(\(self.tuple())"
    }
}

// overload vector addition operator
func +<T: Number>(v1: Vector<T>, v2: Vector<T>) -> Vector<T> {
    return Vector(x: v1.x + v2.x, y: v1.y + v2.y, z: v1.z + v2.z)
}

// overload vector scaling operator
func *<T: Number>(k: T, v: Vector<T>) -> Vector<T> {
    return Vector(x: k * v.x, y: k * v.y, z: k * v.z)
}

// overload unary minus operator
prefix func -<T: Number>(v: Vector<T>) -> Vector<T> {
    return Vector<T>(x: -v.x, y: -v.y, z: -v.z)
}

// wrapper for finding magnitude of Double vectors
func mag(_ v: Vector<Double>) -> Double {
    return sqrt(Vector.mag2(v))
}

typealias Vec3d = Vector<Double>
typealias Vec3i = Vector<Int>

// casts an Int vector into a Double vector
func iVec2dVec (_ v: Vec3i) -> Vec3d {
    return Vector(x: Double(v.x), y: Double(v.y), z: Double(v.z))
}

// multiplies Int vector by Double. Implemented due to issues in line 187 (self.e3)
func iVecTimesD (v: Vec3i, d: Double) -> Vec3d {
    return Vector(x: Double(v.x)*d, y: Double(v.y)*d, z: Double(v.z)*d)
}

// a class for handling cuboid transformations and inverse-transformations
class Cuboid {
    var e1, e2, e3: Vec3d // vectors along the 3 primary directions of cuboid
    var n1, n2, n3: Vec3d // normal vectors along these directions
    var l1, l2, l3: Double // dimensions of the cuboid
    var vertices: [Vec3d] = [Vec3d](repeating: Vec3d(x: 0.0, y: 0.0, z: 0.0), count: 8) // 8 cube vertices
    var cells: [Cell] // the remapped cells
    
    init(u1: Vec3i, u2: Vec3i, u3: Vec3i) {
        // set primary direction vectors
        if (Vector.tripleScalarProduct(v1: u1, v2: u2, v3: u3) == 1) {
            let s1: Double = Double(Vector.mag2(u1))
            let s2: Double = Double(Vector.mag2(u2))
            let d12: Double = Double(Vector.dot(u1, u2))
            let d23: Double = Double(Vector.dot(u2, u3))
            let d31: Double = Double(Vector.dot(u3, u1))
            
            let alpha: Double = -d12 / s1
            let gamma: Double = -(alpha * d31 + d23) / (alpha * d12 + s2)
            let beta: Double = -(d31 + gamma * d12) / s1
            
            // assumes that the resulting e1, e2, e3 are mutually orthogonal
            self.e1 = iVec2dVec(u1)
            self.e2 = iVec2dVec(u2) + alpha * iVec2dVec(u1)
            self.e3 = iVec2dVec(u3) + iVecTimesD(v:u1,d:beta) + iVecTimesD(v:u2,d:gamma)
        }
        else {
            print("error: invalid lattice vectors, setting default")
            self.e1 = Vec3d(x: 1.0, y: 0.0, z: 0.0)
            self.e2 = Vec3d(x: 0.0, y: 1.0, z: 0.0)
            self.e3 = Vec3d(x: 0.0, y: 0.0, z: 1.0)
        }
        
        // set dimensions
        self.l1 = mag(self.e1)
        self.l2 = mag(self.e2)
        self.l3 = mag(self.e3)
        
        // set normal vectors
        self.n1 = (1 / self.l1) * self.e1
        self.n2 = (1 / self.l2) * self.e2
        self.n3 = (1 / self.l3) * self.e3
        
        // set vertices
        self.vertices[0] = Vec3d(x: 0.0, y: 0.0, z: 0.0)
        self.vertices[1] = self.vertices[0] + self.e3
        self.vertices[2] = self.vertices[0] + self.e2
        self.vertices[3] = self.vertices[0] + self.e2 + self.e3
        self.vertices[4] = self.vertices[0] + self.e1
        self.vertices[5] = self.vertices[0] + self.e1 + self.e3
        self.vertices[6] = self.vertices[0] + self.e1 + self.e2
        self.vertices[7] = self.vertices[0] + self.e1 + self.e2 + self.e3
        
        let xmin: Double = self.vertices.reduce(Double.infinity)
            { (oldMin, v) -> Double in return min(oldMin, v.x) }
        let xmax: Double = self.vertices.reduce(-Double.infinity)
            { (oldMax, v) -> Double in return max(oldMax, v.x) }
        let ymin: Double = self.vertices.reduce(Double.infinity)
            { (oldMin, v) -> Double in return min(oldMin, v.y) }
        let ymax: Double = self.vertices.reduce(-Double.infinity)
            { (oldMax, v) -> Double in return max(oldMax, v.y) }
        let zmin: Double = self.vertices.reduce(Double.infinity)
            { (oldMin, v) -> Double in return min(oldMin, v.z) }
        let zmax: Double = self.vertices.reduce(-Double.infinity)
            { (oldMax, v) -> Double in return max(oldMax, v.z) }
        
        let ixmin: Int = Int(floor(xmin))
        let ixmax: Int = Int(ceil(xmax))
        let iymin: Int = Int(floor(ymin))
        let iymax: Int = Int(ceil(ymax))
        let izmin: Int = Int(floor(zmin))
        let izmax: Int = Int(ceil(zmax))
        
        self.cells = []
        for ix in ixmin ..< ixmax {
            for iy in iymin ..< iymax {
                for iz in izmin ..< izmax {
                    
                    var c = Cell(ix: ix, iy: iy, iz: iz)
                    let shift = Vec3d(x: Double(-ix), y: Double(-iy), z: Double(-iz))
                    
                    let faces: [Plane] = [
                        Plane(point: self.vertices[0] + shift, normal: self.n1),
                        Plane(point: self.vertices[4] + shift, normal: -self.n1),
                        Plane(point: self.vertices[0] + shift, normal: self.n2),
                        Plane(point: self.vertices[2] + shift, normal: -self.n2),
                        Plane(point: self.vertices[0] + shift, normal: self.n3),
                        Plane(point: self.vertices[1] + shift, normal: -self.n3),
                    ]

                    var skipCell: Bool = false
                    outerloop: for f in faces {
                        switch (self.unitCubeTest(f)) {
                        case +1:
                            break
                        case 0:
                            c.face.append(f)
                            c.nfaces += 1
                            break
                        case -1:
                            skipCell = true
                            break outerloop
                        default:
                            // should not reach here
                            print("error")
                            break
                        }
                    }
                    
                    if (!skipCell) {
                        self.cells.append(c)
                    }
                }
            }
        }
    }
    
    convenience init(u1: (Int, Int, Int), u2: (Int, Int, Int), u3: (Int, Int, Int)) {
        self.init(u1: Vec3i(x: u1.0, y: u1.1, z: u1.2),
            u2: Vec3i(x: u2.0, y: u2.1, z: u2.2),
            u3: Vec3i(x: u3.0, y: u3.1, z: u3.2))
    }
    
    // tests the position of the unit cube relative to Plane p
    // returns +1 if above
    //          0 if intersecting
    //         -1 if below
    fileprivate func unitCubeTest(_ p: Plane) -> Int {
        var above: Int = 0 // set to 1 if any of the unit cube's vertices lie above the plane P
        var below: Int = 0 // set to 1 if any of the unit cube's vertices lie below the plane P
        
        for a in 0 ..< 2 {
            for b in 0 ..< 2 {
                for c in 0 ..< 2 {
                    let s = p.test(x: Double(a), y: Double(b), z: Double(c))
                    
                    if (s > 0) {
                        above = 1
                    }
                    else if (s < 0) {
                        below = 1
                    }
                }
            }
        }
        
        return above - below
    }
    
    func transform(x: Double, y: Double, z: Double, prevCell: Int) -> (pos: (x: Double, y: Double, z: Double), cell: Int) {
        let n = self.cells.count
        for i in prevCell ..< prevCell + n {
            let cellIdx = i % n
            let c: Cell = self.cells[cellIdx]
            
            if (c.contains(x: x, y: y, z: z)) {
                let x1 = x + Double(c.ix)
                let y1 = y + Double(c.iy)
                let z1 = z + Double(c.iz)
                
                let v = Vec3d(x: x1, y: y1, z: z1)
                
                let r1 = Vector.dot(v, self.n1)
                let r2 = Vector.dot(v, self.n2)
                let r3 = Vector.dot(v, self.n3)
                
                return ((r1, r2, r3), cellIdx)
            }
        }
        
        //print("error: point \((x, y, z)) not contained in any cell")
        return ((x, y, z), 0) // dummy return value to keep the compiler happy
    }
    
    func transform(x: Double, y: Double, z: Double) -> (Double, Double, Double) {
        return self.transform(x: x, y: y, z: z, prevCell: 0).pos
    }
    
    func inverseTransform(x _x: Double, y _y: Double, z _z: Double) -> (Double, Double, Double) {
        let v: Vec3d = (_x * self.n1) + (_y * self.n2) + (_z * self.n3)
        
        let x1: Double = fmod(v.x, 1) + (v.x < 0 ? Double(1.0) : Double(0.0))
        let y1: Double = fmod(v.y, 1) + (v.y < 0 ? Double(1.0) : Double(0.0))
        let z1: Double = fmod(v.z, 1) + (v.z < 0 ? Double(1.0) : Double(0.0))
        
        return (x1, y1, z1)
    }
    
    func getDimensions() -> (l1: Double, l2: Double, l3: Double) {
        return (self.l1, self.l2, self.l3)
    }
    
}
