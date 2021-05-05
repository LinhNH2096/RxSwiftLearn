//
//  TimerViewController.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 04/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

class TimerViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        
        let up = button.rx.controlEvent(.touchUpInside)
        let down = button.rx.controlEvent(.touchDown)
        
        down
            .flatMapLatest { _ in
                return  Observable<Int>
                    .interval(.milliseconds(1), scheduler: MainScheduler.instance)
                    .map { _  in
                        return dateFormatter.string(from: Date())
                    }
                    .take(until: up)
            }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }

}
