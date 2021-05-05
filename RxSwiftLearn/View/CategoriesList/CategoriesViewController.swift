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
        categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.cocktailTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        fetchAPI()
    }
    
    private func configureUI() {
        cocktailTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchAPI() {
        let newCategories = NetWorking.share().getCategory(kind: "c")
        let downloadItems = newCategories.flatMap { categories -> Observable<Observable<[Drink]>> in
            return Observable.from(categories.map({ category -> Observable<[Drink]> in
                NetWorking.share().getDrinks(kind: "c", value: category.nameCategory)
            }))
        }.merge(maxConcurrent: 2)
        
        let updatedCategories = newCategories.flatMap { categories -> Observable<[CocktailCategory]> in
            downloadItems
                .enumerated()
                .scan([]) { (updated, category) -> [CocktailCategory] in
                    let (index, drinks) = category
                    var new: [CocktailCategory] = updated
                    new.append(CocktailCategory(nameCategory: categories[index].nameCategory, items: drinks))
                    return new
                }
        }
        updatedCategories
            .bind(to: categories)
            .disposed(by: disposeBag)
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
        let item = categories.value[indexPath.row]
        let categoryDetailViewController =
            CategoryDetailViewController(nibName: String(describing: CategoryDetailViewController.self),
                                         bundle: nil)
        categoryDetailViewController.categoryName = item.nameCategory
        self.navigationController?.pushViewController(categoryDetailViewController, animated: true)
    }
}
