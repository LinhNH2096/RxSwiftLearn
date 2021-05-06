//
//  CocktailViewController.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController {

    @IBOutlet weak var cocktailTableView: UITableView!
    private let disposeBag = DisposeBag()
    private let categories = BehaviorRelay<[CocktailCategory]>(value: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindingData()
//        readDataFromCache()
        fetchAPI()
    }
    
    private static func cacheFileInURL(_ fileName: String) -> URL? {
        return FileManager
            .default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first?
            .appendingPathComponent(fileName)
    }
    
    private var cacheFileURL = cacheFileInURL("drinks.json")
    
    private func configureUI() {
        cocktailTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func bindingData() {
        categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.cocktailTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func readDataFromCache() {
        guard let url = cacheFileURL,
            let drinkCachedData = try? Data(contentsOf: url),
            let preDrinks = try? JSONDecoder().decode([CocktailCategory].self, from: drinkCachedData)
        else { return }
        print(preDrinks)
        categories.accept(preDrinks)
    }
    
    private func fetchAPI() {
        let newCategories = NetWorking.share().getCategory(kind: "c")
        // #flagMap: make Observable<[CocktailCategory]> -> Observable<Observable<[Drink]>>#
                    // Create Observable from Array categories
                            //-> map categories array -> change to Observable<[Drink]> by call getDrinks func
                            //=> result of map operator is [Observable<[Drink]>] which is resource of Observable create by from func ( this Observable will emit Observable<[Drink] element - type of it is Observable<Observable<[Drink]>>
        
        // After using merge func => downloadItems is Observable<[Drink]>
        let categoryDrinkItems = newCategories.flatMap { categories -> Observable<Observable<[Drink]>> in
            return Observable
                .from(categories
                        .map({ category -> Observable<[Drink]> in
                            return NetWorking.share().getDrinks(kind: "c", value: category.nameCategory)
                        })
                )
        }.merge(maxConcurrent: 2)
        
        let completionCategories = newCategories.flatMap { categories -> Observable<[CocktailCategory]> in
            var new: [CocktailCategory] = []
            return categoryDrinkItems
                .enumerated()
                .map { category -> [CocktailCategory] in
                    let (index, drinks) = category
                    new.append(CocktailCategory(nameCategory: categories[index].nameCategory, items: drinks))
                    return new
                }
        }
        // Bind to BehaviorReplay categories
        completionCategories
            .bind(to: categories)
            .disposed(by: disposeBag)
        
        // Save to disk
        completionCategories
            .asObservable()
            .subscribe(onNext: {[weak self] categories in
               let dataDrinks = try? JSONEncoder().encode(categories)
                if let url = self?.cacheFileURL {
                    try? dataDrinks?.write(to: url, options: .atomicWrite)
                }
            }).disposed(by: disposeBag)
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cocktailTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = categories.value[indexPath.row]
        cell.textLabel?.text = "\(item.nameCategory) - \(item.items.count) items"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cocktailTableView.deselectRow(at: indexPath, animated: false)
        let item = categories.value[indexPath.row]
        let categoryDetailViewController =
            CategoryDetailViewController(nibName: String(describing: CategoryDetailViewController.self),
                                         bundle: nil)
        categoryDetailViewController.categoryName = item.nameCategory
        categoryDetailViewController.listItems.accept(item.items)
        self.navigationController?.pushViewController(categoryDetailViewController, animated: true)
    }
    
}
