//
//  Structures.swift
//  gadget_test_2
//
//  Created by Ray Ye on 6/18/18.
//  Copyright © 2018 Peter Lee. All rights reserved.
//

import Foundation

public class Node<T>{
    var next : Node<T>?
    weak var prev : Node<T>?
    var value : T
    init(value : T){
        self.value = value
        self.next = nil
    }
}

public class LinkedList<T>{
    private weak var head : Node<T>?
    private var tail : Node<T>?
    private(set) var size : UInt
    
    init(){
        self.size = 0
    }
    
    deinit{
        self.clear()
    }
    
    func enq(value : T) {
        let node = Node(value: value)
        if(self.size == 0){
            self.tail = node
        }
        else{
            let temp = self.head!
            node.next = temp
            temp.prev = node
        }
        self.head = node
        self.size += 1
    }
    
    func deq() -> T?{
        if(self.size == 0){
            return nil
        }
        let toRem = self.tail!
        self.tail = toRem.prev
        toRem.prev?.next = nil
        self.size -= 1
        let res = toRem.value
        return res
    }
    
    func valAt(location : UInt) -> T? {
        if(self.size == 0 || location >= self.size){
            return nil
        }
        var curNode = self.tail!
        while (location != 0) {
            curNode = curNode.prev!
        }
        return curNode.value
    }
    
    func remove(){
        if(self.size == 0){
            return
        }
        self.tail = self.tail?.prev
        self.tail?.next = nil
        self.size -= 1
    }
    
    func clear(){
        while (self.size != 0) {
            self.remove()
        }
    }
    
}
