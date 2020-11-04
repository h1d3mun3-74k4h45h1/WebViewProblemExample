//
//  GCD.swift
//
//  Created by Le Van Nghia on 7/25/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import Foundation

public typealias GCDClosure = () -> Void
public typealias GCDApplyClosure = (Int) -> Void
public typealias GCDOnce = Int

public enum QueueType {
    case main
    case high
    case `default`
    case low
    case background
    case custom(GCDQueue)

    public func getQueue() -> DispatchQueue {
        switch self {
        // return concurrent queue with hight priority
        case .high:
            return DispatchQueue.global(qos: .userInitiated)

        // return concurrent queue with default priority
        case .default:
            return DispatchQueue.global(qos: .default)

        // return concurrent queue with low priority
        case .low:
            return DispatchQueue.global(qos: .utility)

        // return background concurrent queue
        case .background:
            return DispatchQueue.global(qos: .background)

        // return custom queue
        case let .custom(gcdQueue):
            return gcdQueue.dispatchQueue

        // return the serial dispatch queue associated with the application’s main thread
        case .main:
            fallthrough

        default:
            return DispatchQueue.main
        }
    }
}

open class GCDQueue {
    let dispatchQueue: DispatchQueue

    /**
     *  Init with main queue (tasks execute serially on your application’s main thread)
     */
    public init() {
        dispatchQueue = DispatchQueue.main
    }

    /**
     *  Init with a serial queue (tasks execute one at a time in FIFO order)
     *
     *  @param label (can be nil)
     */
    public init(serial label: String?) {
        if label != nil {
            dispatchQueue = DispatchQueue(label: label!, attributes: [])
        } else {
            dispatchQueue = DispatchQueue(label: "")
        }
    }

    /**
     *  Init with concurrent queue (tasks are dequeued in FIFO order, but run concurrently and can finish in any order)
     *
     *  @param label (can be nil)
     */
//    public init(concurrent label: String?) {
//        if label != nil {
//            dispatchQueue = DispatchQueue(label: label!, attributes: DispatchQueue.Attributes.concurrent)
//        }
//        else {
//            dispatchQueue = DispatchQueue(label: nil, attributes: DispatchQueue.Attributes.concurrent)
//        }
//    }

    /**
     *  Submits a barrier block for asynchronous execution and returns immediately
     *
     *  @param GCDClosure
     *
     */
    open func asyncBarrier(_ closure: @escaping GCDClosure) {
        dispatchQueue.async(flags: .barrier, execute: closure)
    }

    /**
     *  Submits a barrier block object for execution and waits until that block completes
     *
     *  @param GCDClosure
     *
     */
    open func syncBarrier(_ closure: GCDClosure) {
        dispatchQueue.sync(flags: .barrier, execute: closure)
    }

    /**
     *  suspend queue
     *
     */
    open func suspend() {
        dispatchQueue.suspend()
    }

    /**
     *  resume queue
     *
     */
    open func resume() {
        dispatchQueue.resume()
    }
}

open class GCDGroup {
    let dispatchGroup: DispatchGroup

    public init() {
        dispatchGroup = DispatchGroup()
    }

    open func enter() {
        dispatchGroup.enter()
    }

    open func leave() {
        dispatchGroup.leave()
    }

    /**
     *  Waits synchronously for the previously submitted block objects to complete
     *  returns if the blocks do not complete before the specified timeout period has elapsed
     *
     *  @param Double timeout in second
     *
     *  @return all blocks associated with the group completed before the specified timeout or not
     */
    open func wait(_ timeout: Double) -> Bool {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        return dispatchGroup.wait(timeout: dispatchTime) == .success
    }

    /**
     *  Submits a block to a dispatch queue and associates the block with current dispatch group
     *
     *  @param QueueType
     *  @param GCDClosure
     *
     */
//    open func async(_ queueType: QueueType, closure: GCDClosure) {
//        queueType.getQueue().async(group: dispatchGroup, execute: closure)
//    }

    /**
     *  Schedules a block object to be submitted to a queue when
     *  previously submitted block objects of current group have completed
     *
     *  @param QueueType
     *  @param GCDClosure
     *
     */
    open func notify(_ queueType: QueueType, closure: @escaping GCDClosure) {
        dispatchGroup.notify(queue: queueType.getQueue(), execute: closure)
    }
}

open class gcd {
    /**
     *  Async
     *  Submits a block for asynchronous execution on a dispatch queue and returns immediately
     *
     *  @param QueueType  : the queue (main or serially or concurrently) on which to submit the block
     *  @param GCDClosure : the block will be run
     *
     */
    open class func async(_ queueType: QueueType, closure: @escaping GCDClosure) {
        queueType.getQueue().async(execute: closure)
    }

    // Enqueue a block for execution at the specified time
    open class func async(_ queueType: QueueType, delay: Double, closure: @escaping GCDClosure) {
        let t = delay * Double(NSEC_PER_SEC)
        queueType.getQueue().asyncAfter(deadline: DispatchTime.now() + Double(Int64(t)) / Double(NSEC_PER_SEC), execute: closure)
    }

    /**
     *  Sync
     *  Submits a block object for execution on a dispatch queue and waits until that block completes
     *
     *  @param QueueType  :  the queue (main or serially or concurrently) on which to submit the block
     *  @param GCDClosure :  the block will be run
     *
     */
    open class func sync(_ queueType: QueueType, closure: GCDClosure) {
        queueType.getQueue().sync(execute: closure)
    }

    /**
     *  dispatch apply
     *  this method waits for all iterations of the task block to complete before returning
     *
     *  @param QueueType       :  the queue (main or serially or concurrently) on which to submit the block
     *  @param UInt            :  the number of iterations to perform
     *  @param GCDApplyClosure :  the block will be run
     *
     */
    open class func apply(_: QueueType, interators: UInt, closure: GCDApplyClosure) {
        DispatchQueue.concurrentPerform(iterations: Int(interators), execute: closure)
    }

    /**
     *
     *
     *  @param UnsafePointer<dispatch_once_t>
     *  @param GCDClosure
     *
     *  @return
     */
//    open class func once(_ predicate: UnsafeMutablePointer<Int>, closure: GCDClosure) {
//        dispatch_once(predicate, closure)
//    }
}
