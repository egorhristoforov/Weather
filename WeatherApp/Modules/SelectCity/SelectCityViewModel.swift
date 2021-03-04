//
//  SelectCityViewModel.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift
import RxCocoa

class SelectCityViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let apiService: ApiServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    
    private let country: Country
    
    struct Input {
        let didSelectedRow: AnyObserver<Int>
        let didClose: AnyObserver<Void>
        let searchText: AnyObserver<String>
    }
    
    let input: Input
    
    private let didSelectedRowSubject = PublishSubject<Int>()
    var didSelectedCity: Observable<City> {
        return didSelectedRowSubject
            .withLatestFrom(output.cities) { ($0, $1) }
            .filter { $1.count > $0 }
            .map { $1[$0] }
    }
    
    private let didCloseSubject = PublishSubject<Void>()
    var didClose: Observable<Void> {
        return didCloseSubject
            .asObservable()
    }
    
    private let searchTextSubject = BehaviorSubject<String>(value: "")
    
    struct Output {
        let title: String
        let cities: Driver<[City]>
        let isCitiesLoading: Driver<Bool>
    }
    
    let output: Output
    
    private let citiesRelay = BehaviorRelay<[City]>(value: [])
    private let isCitiesLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    init(country: Country, apiService: ApiServiceProtocol, databaseService: DatabaseServiceProtocol) {
        self.country = country
        self.apiService = apiService
        self.databaseService = databaseService
        
        input = Input(didSelectedRow: didSelectedRowSubject.asObserver(),
                      didClose: didCloseSubject.asObserver(),
                      searchText: searchTextSubject.asObserver())
        
        let cities = Observable.combineLatest(citiesRelay, searchTextSubject)
            .flatMap { cities, search -> Observable<[City]> in
                search.isEmpty ? .just(cities) :
                    .just(cities.filter { $0.name.range(of: search, options: [.caseInsensitive, .anchored]) != nil })
            }
            .asDriver(onErrorJustReturn: [])
        
        let isCitiesLoading = isCitiesLoadingRelay
            .asDriver()
        
        output = Output(title: country.name,
                        cities: cities,
                        isCitiesLoading: isCitiesLoading)
        
        loadCitiesList()
        
        didSelectedCity
            .subscribe(onNext: { city in
                databaseService.saveSelectedCity(city: city)
            })
            .disposed(by: disposeBag)
    }
}

private extension SelectCityViewModel {
    func loadCitiesList() {
        isCitiesLoadingRelay.accept(true)
        
        apiService.getCitiesListForCountry(with: country.id)
            .catch(handleCitiesLoadError)
            .map { $0.map { City(from: $0) } }
            .do(onNext: { [unowned self] _ in
                isCitiesLoadingRelay.accept(false)
            })
            .bind(to: citiesRelay)
            .disposed(by: disposeBag)
    }
    
    func handleCitiesLoadError(_ error: Error) -> Observable<[CityObject]> {
        // TODO: Show error alert
        return .just([])
    }
}
