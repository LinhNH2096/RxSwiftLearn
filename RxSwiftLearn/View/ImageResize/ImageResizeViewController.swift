//
//  ImageResizeViewController.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 04/05/2021.
//

import UIKit
import RxCocoa
import RxSwift

class ImageResizeViewController: UIViewController {

    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        scrollView.rx.parallex(amount: 2.0)
//            .bind(to: imageTop.rx.constant)
//            .disposed(by: disposeBag)
        let initialHeight = imageHeight.constant
        scrollView.rx
            .resizeHeight(initialHeight: initialHeight)
            .bind(to: imageHeight.rx.constant)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: UIScrollView {
    func parallex(amount: CGFloat = 3.0) -> Observable<CGFloat> {
        return base.rx.contentOffset
            .map { -$0.y / amount }
            .map { max(0, $0)}
    }
    
    func resizeHeight(initialHeight: CGFloat, amount: CGFloat = 1) -> Observable<CGFloat> {
        return base.rx.contentOffset
            .map{ $0.y / amount}
            .map{ max(initialHeight, initialHeight - $0)}
    }
    
}
