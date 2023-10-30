import UIKit
import SnapKit
import MapKit
import Combine
import ComposableArchitecture

final class SnapMatchViewController: UIViewController {
    struct ViewState: Equatable {
        let isPeopleCountHidden: Bool
        let isStopButtonHidden: Bool
        let peopleCount: Int
        let queueNumber: Int

        init(state: SnapMatchFeature.State) {
            self.isPeopleCountHidden = state.isPeopleCountHidden
            self.isStopButtonHidden = state.isStopButtonHidden
            self.peopleCount = state.peopleCount
            self.queueNumber = state.queueNumber
        }
    }

    private lazy var popupView: SnapMatchPopupView = {
        let view = SnapMatchPopupView(
            store: self.store.scope(
                state: \.popup,
                action: SnapMatchFeature.Action.popup
            )
        )
        view.layer.cornerRadius = 16.0
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private lazy var mapView = MKMapView(frame: .zero)

    private lazy var stopButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.sizeToFit()
        return label
    }()

    private lazy var peopleCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    private lazy var queueNumerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    let store: StoreOf<SnapMatchFeature>
    let viewStore: ViewStore<ViewState, SnapMatchFeature.Action>
    var cancellables: Set<AnyCancellable> = []

    init(store: StoreOf<SnapMatchFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
    }

    @objc func stopButtonTapped() {
      self.viewStore.send(.stopButtonTapped)
    }

    private func setupSubviews() {
        setupMapView()
        setupPopupView()
        setupStopButton()
        setupTitleLabel()
        setupQueueView()
        setupPeopleCountLabel()
    }

    private func setupMapView() {
        view.addSubview(mapView)

        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupPopupView() {
        view.addSubview(popupView)

        popupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(190)

            if let height = tabBarController?.tabBar.frame.size.height {
                make.bottom.equalToSuperview().offset(-height)
            }
        }
    }

    private func setupStopButton() {
        view.addSubview(stopButton)

        stopButton.snp.makeConstraints {
            $0.topMargin.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(23)
            $0.width.equalTo(69)
            $0.height.equalTo(40)
        }

        stopButton.setTitle("Stop", for: .normal)

        self.viewStore.publisher
            .map(\.isStopButtonHidden)
            .assign(to: \.isHidden, on: stopButton)
            .store(in: &self.cancellables)
    }

    private func setupTitleLabel() {
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.topMargin.equalTo(54)
            $0.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }

        titleLabel.text = "Snap Match"
    }

    private func setupQueueView() {
        let imageView = UIImageView(image: UIImage(named: "thunder"))
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(17)
        }

        let stackView = UIStackView(arrangedSubviews: [imageView, queueNumerLabel])
        stackView.axis = .horizontal
        stackView.spacing = 9.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11, leading: 13, bottom: 11, trailing: 13)

        stackView.layer.cornerRadius = 20.0
        stackView.clipsToBounds = true
        stackView.backgroundColor = .black

        view.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.topMargin.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-34)
        }

        self.viewStore.publisher
            .map { "\($0.queueNumber)" }
            .assign(to: \.text, on: queueNumerLabel)
            .store(in: &self.cancellables)
    }

    private func setupPeopleCountLabel() {
        let imageView = UIImageView(image: UIImage(named: "Oval"))
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(6)
        }

        let stackView = UIStackView(arrangedSubviews: [imageView ,peopleCountLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)

        stackView.layer.cornerRadius = 12.0
        stackView.clipsToBounds = true
        stackView.backgroundColor = .black

        view.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.bottom.equalTo(popupView.snp_topMargin).offset(-16)
            $0.centerX.equalToSuperview()
        }

        self.viewStore.publisher
            .map(\.isPeopleCountHidden)
            .assign(to: \.isHidden, on: stackView)
            .store(in: &self.cancellables)

        self.viewStore.publisher
            .map { "\($0.peopleCount.formattedValue) people online" }
            .assign(to: \.text, on: peopleCountLabel)
            .store(in: &self.cancellables)
    }
}

private extension Formatter {
    static var valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

private extension Int {
    var formattedValue: String {
        let number = NSNumber(value: self)
        guard let formatted = Formatter.valueFormatter.string(from: number) else {
            return "\(self)"
        }
        return formatted
    }
}
