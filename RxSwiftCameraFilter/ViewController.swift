//
//  ViewController.swift
//  RxSwiftCameraFilter
//
//  Created by usr on 2021/7/26.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var applyFilterButton: UIButton!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController,
              let photos = nav.viewControllers.first as? PhotoCollectionViewController else { fatalError() }
        
        // ➡️ 訂閱(subscribe) Observable 得到圖片
        photos.selectedPhoto.subscribe(onNext: { [weak self] photo in
            DispatchQueue.main.async {
                self?.photoImageView.image = photo
                self?.applyFilterButton.isHidden = false
            }
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(with image: UIImage) {
        
    }
}

