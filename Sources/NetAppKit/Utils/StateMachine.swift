//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

internal class StateMachine<Delegate: StateMachineDelegate> {
    
    internal private(set) var state: Delegate.State
    
    internal weak var delegate: Delegate?
    
    internal init(initialState: Delegate.State) {
        state = initialState
    }
    
    internal func fireEvent(_ event: Delegate.Event) {
        if let newState = delegate?.stateToTransitionTo(from: state, dueTo: event) {
            delegate?.willTransition(from: state, to: newState, dueTo: event)
            let oldState = state
            state = newState
            delegate?.didTransition(from: oldState, to: state, dueTo: event)
        }
    }
}

internal protocol StateMachineDelegate: AnyObject {
    
    associatedtype State
    associatedtype Event
    
    /// Return state to transition to from the current state given an event.
    /// Return nil to not trigger a transition.
    /// Return the from state for a loopback transition to itself.
    func stateToTransitionTo(from state: State, dueTo event: Event) -> State?
    
    func willTransition(from state: State, to newState: State, dueTo event: Event)
    
    func didTransition(from state: State, to newState: State, dueTo event: Event)
}
