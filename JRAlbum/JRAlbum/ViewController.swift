//
//  ViewController.swift
//  JRAlbum
//
//  Created by 京睿 on 2017/9/12.
//  Copyright © 2017年 JingRuiWangKe. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class ViewController: UIViewController {
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isAuthorized = PHPhotoLibrary.isAuthorized.share()
        
        isAuthorized
            .skipWhile(!)
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe( onNext: { [weak self] _ in
                if let `self` = self {
                    
                }
                print("授权成功")
            })
            .addDisposableTo(bag)
        
        isAuthorized
            .distinctUntilChanged()
            .takeLast(1)
            .filter(!)
            .subscribe(onNext: { _ in
                print("授权失败")
            })
            .addDisposableTo(bag)
    }
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: options)
    }
}

extension PHPhotoLibrary {
    static var isAuthorized: Observable<Bool> {
        return Observable.create {
            observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    requestAuthorization {
                        observer.onNext($0 == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
