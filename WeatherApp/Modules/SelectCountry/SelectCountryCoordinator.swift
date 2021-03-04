//
//  SelectCountryCoordinator.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift

class SelectCountryCoordinator: Coordinator<SelectCityCoordinationResult> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<SelectCityCoordinationResult> {
        let viewModel = SelectCountryViewModel(apiService: ApiService())
        let viewController = SelectCountryViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
        
        let didSelectedCity = viewModel.didSelectedCountry
            .flatMap { [unowned self] country -> Observable<SelectCityCoordinationResult> in
                let coordinator = SelectCityCoordinator(navigationController: navigationController, country: country)
                return coordinate(to: coordinator)
            }
            .filter { $0 != .closed }
        
        return Observable.merge(viewModel.didClose.map { .closed },
                                didSelectedCity)
            .take(1)
    }
}
