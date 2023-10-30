import Foundation
import ComposableArchitecture

struct SnapMatchFeature: Reducer {
    enum Step {
        case initial
        case matching
        case matchResults
    }

    struct State: Equatable {
        fileprivate var step = Step.initial {
            didSet {
                popup = SnapMatchPopupFeature.State(step: step)
            }
        }

        var popup = SnapMatchPopupFeature.State(step: .initial)

        var isPeopleCountHidden: Bool {
            step != .initial
        }

        var isStopButtonHidden: Bool {
            step == .initial
        }

        var peopleCount: Int {
            Int.random(in: 5_000...10_000)
        }

        var queueNumber: Int {
            Int.random(in: 1...5)
        }
    }

    enum Action: Equatable {
        case stopButtonTapped
        case popup(SnapMatchPopupFeature.Action)
        case getMatchResults
    }

    enum CancelID { case search }

    var body: some Reducer<State, Action> {
        Scope(state: \.popup, action: /Action.popup) {
          SnapMatchPopupFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .stopButtonTapped:
                state.step = .initial
                return .cancel(id: CancelID.search)

            case .popup(.tapToMatchTapped):
                guard state.step == .initial else {
                    return .none
                }
                state.step = .matching
                return .run { send in
                    try await Task.sleep(nanoseconds: 1_000_000_000 * UInt64.random(in: 5...10))
                    await send(.getMatchResults)
                }
                .cancellable(id: CancelID.search)

            case .getMatchResults:
                state.step = .matchResults
                return .none
            }
        }
    }
}

extension SnapMatchPopupFeature.State {
    init(step: SnapMatchFeature.Step) {
        switch step {
        case .initial:
            self.title = "Tap to match"
            self.subtitle = "Start chatting with people worldwide"
            self.animation = Animations.tap.rawValue

        case .matching:
            self.title = "Hang Tight"
            self.subtitle = "Matching you with someone..."
            self.animation = Animations.location.rawValue

        case .matchResults:
            self.title = "Yay!"
            self.subtitle = "Here is your match."
            self.animation = Animations.location.rawValue
        }
    }
}

private enum Animations: String {
    case tap = "Tap_animation"
    case location = "Location_animation"
}
