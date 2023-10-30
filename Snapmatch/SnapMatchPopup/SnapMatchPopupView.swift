import UIKit
import Lottie
import Combine
import ComposableArchitecture

final class SnapMatchPopupView: UIView {

    private lazy var animationView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.loopMode = .loop
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapAnimationView))
        animationView.addGestureRecognizer(tapGesture)
        return animationView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .red
        label.sizeToFit()
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.sizeToFit()
        return label
    }()

    let viewStore: ViewStoreOf<SnapMatchPopupFeature>
    var cancellables: Set<AnyCancellable> = []

    init(store: StoreOf<SnapMatchPopupFeature>) {
        self.viewStore = ViewStore(store, observe: { $0 })
        super.init(frame: .zero)

        backgroundColor = .black

        setupAnimationView()
        setupTitleLabel()
        setupSubtitleLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAnimationView() {
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false

        animationView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-12.0)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(148)
        }

        self.viewStore.publisher
            .map(\.animation)
            .sink(receiveValue: { [weak self] in
                self?.animationView.animation = LottieAnimation.named($0)
                self?.animationView.play()
            })
            .store(in: &self.cancellables)
    }

    @objc func onTapAnimationView() {
      self.viewStore.send(.tapToMatchTapped)
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(122.0)
            $0.centerX.equalToSuperview()
        }

        self.viewStore.publisher
            .map(\.title)
            .assign(to: \.text, on: titleLabel)
            .store(in: &self.cancellables)
    }

    private func setupSubtitleLabel() {
        addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(155.0)
            $0.centerX.equalToSuperview()
        }

        self.viewStore.publisher
            .map(\.subtitle)
            .assign(to: \.text, on: subtitleLabel)
            .store(in: &self.cancellables)
    }
}
