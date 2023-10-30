import Foundation
import ComposableArchitecture

struct SnapMatchPopupFeature: Reducer {
    struct State: Equatable {
        let title: String?
        let subtitle: String?
        let animation: String
    }

    enum Action: Equatable {
        case tapToMatchTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tapToMatchTapped:
                return .none
            }
        }
    }
}
