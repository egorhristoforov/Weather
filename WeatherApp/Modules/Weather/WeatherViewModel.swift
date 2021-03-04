//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift
import RxCocoa

class WeatherViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let apiService: ApiServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    
    struct Input {
        let didTapSelectCityButton: AnyObserver<Void>
        let viewWillAppear: AnyObserver<Void>
    }
    
    let input: Input
    
    private let didTapSelectCityButtonSubject = PublishSubject<Void>()
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    var didTapSelectCityButton: Observable<Void> {
        return didTapSelectCityButtonSubject
            .asObservable()
    }
    
    struct Output {
        let cityName: Driver<String>
        let cityCoordinates: Driver<CityCoordinates?>
        let currentWeather: Driver<CurrentWeather?>
        
        let weatherHistory: Driver<[WeatherHistory]>
        
        let isLoading: Driver<Bool>
    }
    
    let output: Output
    
    private let weatherHistorySubject = BehaviorSubject<WeatherList?>(value: nil)
    private let currentWeatherSubject = BehaviorSubject<CurrentWeather?>(value: nil)
    
    private let isLoadingWeatherHistoryRelay = BehaviorRelay<Bool>(value: false)
    private let isLoadingCurrentWeatherRelay = BehaviorRelay<Bool>(value: false)
    
    init(apiService: ApiServiceProtocol, databaseService: DatabaseServiceProtocol) {
        self.apiService = apiService
        self.databaseService = databaseService
        
        input = Input(didTapSelectCityButton: didTapSelectCityButtonSubject.asObserver(),
                      viewWillAppear: viewWillAppearSubject.asObserver())
        
        let cityCoordinates = currentWeatherSubject
            .map { $0?.coordinates }
            .asDriver(onErrorJustReturn: nil)
        
        let cityName = databaseService.selectedCity
            .compactMap { $0?.name }
            .asDriver(onErrorJustReturn: "")
        
        let isLoading = Observable.combineLatest(isLoadingCurrentWeatherRelay,
                                                 isLoadingWeatherHistoryRelay)
            .map { $0 || $1 }
            .asDriver(onErrorJustReturn: false)
        
        let currentWeather = currentWeatherSubject
            .asDriver(onErrorJustReturn: nil)
        
        let weatherHistory = weatherHistorySubject
            .map { $0?.weatherHistory ?? [] }
            .asDriver(onErrorJustReturn: [])
        
        output = Output(cityName: cityName,
                        cityCoordinates: cityCoordinates,
                        currentWeather: currentWeather,
                        weatherHistory: weatherHistory,
                        isLoading: isLoading)
        
        let reloadWeather = viewWillAppearSubject
            .withLatestFrom(databaseService.selectedCity) { $1 }
            .distinctUntilChanged()
            .compactMap { $0 }
        
        reloadWeather
            .flatMap { [unowned self] city -> Observable<WeatherListObject> in
                isLoadingWeatherHistoryRelay.accept(true)
                weatherHistorySubject.onNext(nil)
                return apiService.getWeatherHistoryFor(city: city.name)
                    .catch(handleApiError)
            }
            .map { WeatherList(from: $0) }
            .do(onNext: { [unowned self] _ in
                isLoadingWeatherHistoryRelay.accept(false)
            })
            .bind(to: weatherHistorySubject)
            .disposed(by: disposeBag)
        
        reloadWeather
            .flatMap { [unowned self] city -> Observable<CurrentWeatherObject> in
                isLoadingCurrentWeatherRelay.accept(true)
                currentWeatherSubject.onNext(nil)
                return apiService.getCurrentWeatherFor(city: city.name)
                    .catch(handleApiError)
            }
            .map { CurrentWeather(from: $0) }
            .do(onNext: { [unowned self] _ in
                isLoadingCurrentWeatherRelay.accept(false)
            })
            .bind(to: currentWeatherSubject)
            .disposed(by: disposeBag)
    }
}

private extension WeatherViewModel {
    func handleApiError<T>(_ error: Error) -> Observable<T> {
        // TODO: Handle error
        return .empty()
    }
}
