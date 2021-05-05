//
//  CategoryDetailViewController.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 05/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryDetailViewController: UIViewController {

    @IBOutlet weak var listItemsTableView: UITableView!
    var categoryName: String = ""
    private var listItems = BehaviorRelay<[Drink]>(value: [])
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindingListItemsTableView()
        fetchData()
    }
    
    private func configureUI() {
        listItemsTableView
            .register(UINib(nibName: ItemTableViewCell.cellIdentifier,
                            bundle: nil),
                      forCellReuseIdentifier: ItemTableViewCell.cellIdentifier)
    }
    
    private func bindingListItemsTableView() {
        listItems
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.title = "\(self.categoryName) - \(self.listItems.value.count) items"
                    self.listItemsTableView.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    private func fetchData() {
        NetWorking
            .share()
            .getDrinks(kind: "c", value: categoryName)
            .bind(to: listItems)
            .disposed(by: disposeBag)
    }
}

extension CategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = listItemsTableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.cellIdentifier, for: indexPath) as? ItemTableViewCell
        else {return UITableViewCell()}
        let item = listItems.value[indexPath.row]
        cell.setUpWith(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
}
