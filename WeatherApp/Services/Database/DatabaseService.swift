//
//  DatabaseService.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift
import SQLite

protocol DatabaseServiceProtocol {
    func getSelectedCity() -> City?
    func saveSelectedCity(city: City)
    
    var selectedCity: Observable<City?> { get }
}

class DatabaseService: DatabaseServiceProtocol {
    
    private let selectedCitySubject = BehaviorSubject<City?>(value: nil)
    var selectedCity: Observable<City?> {
        return selectedCitySubject
            .asObservable()
    }
    
    static let shared = DatabaseService()
    private let connection: Connection?
    
    private let actualDatabaseVersion = 1
    
    private let selectedCityTable = Table("SelectedCity")
    
    private init(){
        do {
            let fileManager = FileManager.default
            
            let dbPath = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("storage.db")
                .path
            
            if !fileManager.fileExists(atPath: dbPath) {
                let dbResourcePath = Bundle.main.path(forResource: "storage", ofType: "db")!
                try fileManager.copyItem(atPath: dbResourcePath, toPath: dbPath)
            }
            
            connection = try Connection(dbPath)
            setupAllTables()
        } catch {
            connection = nil
            let nserror = error as NSError
            #if DEBUG
            print ("Cannot connect to Database. Error is: \(nserror), \(nserror.userInfo)")
            #endif
        }
        
        selectedCitySubject.onNext(getSelectedCity())
    }
    
    // MARK: - Создание таблицы
    
    private func setupAllTables() {
        
        if (connection?.databaseVersion ?? -1) < actualDatabaseVersion {
            do {
                try connection?.run(selectedCityTable.drop(ifExists: true))
                connection?.databaseVersion = Int32(actualDatabaseVersion)
            } catch {
                #if DEBUG
                print("Drop Order table error: \(error)")
                #endif
            }
        }
        
        createSelectedCityTable()
    }
    
    private func createSelectedCityTable() {
        do {
            try connection?.run(self.selectedCityTable.create(temporary: false, ifNotExists: true) { t in
                t.column(SelectedCityTable.id, primaryKey: .default)
                t.column(SelectedCityTable.name)
            })
        } catch {
            #if DEBUG
            print("Create selected city table error: \(error)")
            #endif
        }
    }
    
    // MARK: - Получение сохраненого города из БД
    
    func getSelectedCity() -> City? {
        do {
            guard let connection = connection else { return nil }
            let query = selectedCityTable.select(selectedCityTable[*])
            
            guard let savedCityRow = try connection.pluck(query) else { return nil }
            
            let cityId = try savedCityRow.get(SelectedCityTable.id)
            let cityName = try savedCityRow.get(SelectedCityTable.name)
            
            return City(id: cityId, name: cityName)
        } catch {
            #if DEBUG
            print("Get selected city error", error)
            #endif
            
            return nil
        }
    }
    
    // MARK: - Сохранение города в БД
    
    func saveSelectedCity(city: City) {
        do {
            guard let connection = connection else { return }
            
            // Удаление прошлого сохраненного города
            let existedCityRowQuery = selectedCityTable.select(selectedCityTable[*])
            try connection.run(existedCityRowQuery.delete())
            
            
            let query = selectedCityTable.insert(SelectedCityTable.id <- city.id,
                                                 SelectedCityTable.name <- city.name)
            
            try connection.run(query)
            
            selectedCitySubject.onNext(city)
        } catch {
            #if DEBUG
            print("Save selected city error", error)
            #endif
        }
    }
}

extension Connection {
    // Для миграций храним версию
    public var databaseVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

// Описание таблицы
enum SelectedCityTable {
    static let id = Expression<Int>("id") // PK - ID города
    static let name = Expression<String>("name") // Имя города
}
