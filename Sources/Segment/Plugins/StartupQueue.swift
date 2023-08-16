//
//  StartupQueue.swift
//  Segment
//
//  Created by Brandon Sneed on 6/4/21.
//

import Foundation
import Sovran

public class StartupQueue: Plugin, Subscriber {
    static let maxSize = 1000

    @Atomic public var running: Bool = false
    
    public let type: PluginType = .before
    
    public weak var analytics: Analytics? = nil {
        didSet {
            Analytics.segmentLog(message: "StartupQueue analytics did set.", kind: .debug)
            analytics?.store.subscribe(self, queue: .global()) { [weak self] (state: System) in
                self?.runningUpdate(state: state)
            }
        }
    }
    
    let syncQueue = DispatchQueue(label: "startupQueue.segment.com")
    var queuedEvents = [RawEvent]()
    
    required init() { }
    
    public func execute<T: RawEvent>(event: T?) -> T? {
        Analytics.segmentLog(message: "executing StartupQueue. running: \(running)", kind: .debug)
        if running == false, let e = event  {
            // timeline hasn't started, so queue it up.
            syncQueue.sync {
                if queuedEvents.count >= Self.maxSize {
                    // if we've exceeded the max queue size start dropping events
                    queuedEvents.removeFirst()
                }
                queuedEvents.append(e)
            }
            return nil
        }
        // the timeline has started, so let the event pass.
        return event
    }
}

extension StartupQueue {
    internal func runningUpdate(state: System) {
        running = state.running
        if state.running {
            replayEvents()
        }
    }
    
    internal func replayEvents() {
        // replay the queued events to the instance of Analytics we're working with.
        syncQueue.sync {
            for event in queuedEvents {
                analytics?.process(event: event)
            }
            queuedEvents.removeAll()
        }
    }
}
