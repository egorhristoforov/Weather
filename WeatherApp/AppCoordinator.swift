//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift

class AppCoordinator: Coordinator<Void> {
    private let window: UIWindow
    
    private let selectCountryNavigationController = UINavigationController()
    private let weatherNavigationController = UINavigationController()
    
    private let databaseSerive = DatabaseService.shared
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        if let _ = databaseSerive.getSelectedCity() {
            let weatherCoordinator = WeatherCoordinator(navigationController: weatherNavigationController)
            
            window.rootViewController = weatherNavigationController
            
            coordinate(to: weatherCoordinator)
                .subscribe()
                .disposed(by: disposeBag)
        } else {
            let selectCountryCoordinator = SelectCountryCoordinator(navigationController: selectCountryNavigationController)
            
            window.rootViewController = selectCountryNavigationController
            
            coordinate(to: selectCountryCoordinator)
                .filter { $0 != .closed }
                .flatMap { [unowned self] _ -> Observable<Void> in
                    let weatherCoordinator = WeatherCoordinator(navigationController: weatherNavigationController)
                    
                    window.rootViewController = weatherNavigationController
                    
                    return coordinate(to: weatherCoordinator)
                }
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        window.makeKeyAndVisible()

        return Observable.never()
    }
}
