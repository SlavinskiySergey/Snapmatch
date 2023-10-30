import UIKit
import ComposableArchitecture

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black

        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        }

        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "Home"),
            selectedImage: UIImage(named: "Home_selected")
        )

        let snapMatchVC = SnapMatchViewController(
            store: Store(initialState: SnapMatchFeature.State()) {
                SnapMatchFeature()
            }
        )
        snapMatchVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "Snap_Match"),
            selectedImage: UIImage(named: "Snap_Match_selected")
        )

        self.viewControllers = [homeVC, snapMatchVC]
    }
}

