//
//  SelectCityCoordinator.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift

enum SelectCityCoordinationResult: Equatable {
    case selected(City)
    case closed
    
    static func ==(lhs: SelectCityCoordinationResult, rhs: SelectCityCoordinationResult) -> Bool {
        switch (lhs, rhs) {
        case (.closed, .closed), (.selected(_), .selected(_)):
            return true
        default:
            return false
        }
    }
}

class SelectCityCoordinator: Coordinator<SelectCityCoordinationResult> {
    private let navigationController: UINavigationController
    private let country: Country
    
    init(navigationController: UINavigationController, country: Country) {
        self.navigationController = navigationController
        self.country = country
    }
    
    override func start() -> Observable<SelectCityCoordinationResult> {
        let viewModel = SelectCityViewModel(country: country, apiService: ApiService(), databaseService: DatabaseService.shared)
        let viewController = SelectCityViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
        
        return Observable.merge(viewModel.didClose.map { .closed },
                                viewModel.didSelectedCity.map { .selected($0) })
            .take(1)
    }
}
