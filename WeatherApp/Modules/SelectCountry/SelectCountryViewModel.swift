//
//  SelectCountryViewModel.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift
import RxCocoa

class SelectCountryViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let apiService: ApiServiceProtocol
    
    struct Input {
        let didSelectedRow: AnyObserver<Int>
        let didClose: AnyObserver<Void>
        let searchText: AnyObserver<String>
    }
    
    let input: Input
    
    private let didSelectedRowSubject = PublishSubject<Int>()
    var didSelectedCountry: Observable<Country> {
        
        return didSelectedRowSubject
            .withLatestFrom(output.countries) { ($0, $1) }
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
        let countries: Driver<[Country]>
        let isCountriesLoading: Driver<Bool>
    }
    
    let output: Output
    
    private let countriesRelay = BehaviorRelay<[Country]>(value: [])
    private let isCountriesLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
        
        input = Input(didSelectedRow: didSelectedRowSubject.asObserver(),
                      didClose: didCloseSubject.asObserver(),
                      searchText: searchTextSubject.asObserver())
        
        let countries = Observable.combineLatest(countriesRelay, searchTextSubject)
            .flatMap { countries, search -> Observable<[Country]> in
                search.isEmpty ? .just(countries) :
                    .just(countries.filter { $0.name.range(of: search, options: [.caseInsensitive, .anchored]) != nil })
            }
            .asDriver(onErrorJustReturn: [])
        
        let isCountriesLoading = isCountriesLoadingRelay
            .asDriver()
        
        output = Output(countries: countries,
                        isCountriesLoading: isCountriesLoading)
        
        loadCountriesList()
    }
}

private extension SelectCountryViewModel {
    func loadCountriesList() {
        isCountriesLoadingRelay.accept(true)
        
        apiService.getCountriesList()
            .catch(handleCountiesLoadError)
            .map { $0.map { Country(from: $0) } }
            .do(onNext: { [unowned self] _ in
                isCountriesLoadingRelay.accept(false)
            })
            .bind(to: countriesRelay)
            .disposed(by: disposeBag)
    }
    
    func handleCountiesLoadError(_ error: Error) -> Observable<[CountryObject]> {
        // TODO: Show error alert
        return .just([])
    }
}
