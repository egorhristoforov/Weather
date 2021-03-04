//
//  WeatherCoordinator.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift

class WeatherCoordinator: Coordinator<Void> {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = WeatherViewModel(apiService: ApiService(), databaseService: DatabaseService.shared)
        let viewController = WeatherViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.didTapSelectCityButton
            .flatMap { [unowned self] _ -> Observable<SelectCityCoordinationResult> in
                let coordinator = SelectCountryCoordinator(navigationController: navigationController)
                return coordinate(to: coordinator)
            }
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .selected(_):
                    navigationController.popToRootViewController(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return Observable.never()
    }
}
