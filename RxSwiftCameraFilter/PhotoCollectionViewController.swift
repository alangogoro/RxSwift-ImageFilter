//
//  PhotoCollectionViewController.swift
//  RxSwiftCameraFilter
//
//  Created by usr on 2021/7/26.
//

import Foundation
import UIKit
import RxSwift
import Photos

class PhotoCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    private var images = [PHAsset]()
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObserver()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populatePhotos()
    }
    
    // MARK: - Helper
    private func populatePhotos() {
        /* ➡️ 請求圖庫授權
         * Info.plist 需要新增 Privacy - Photo Library Usage Description 的 Key */
        /* 🌟 此處要撈取大量的資源，在非同步作業時加上[weak self] 避免記憶體洩漏 */
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                
                /* 取用圖庫中的「圖片」類媒體 */
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                // 遍歷圖片加入成此頁的屬性
                assets.enumerateObjects { (object, count, stop) in
                    self?.images.append(object)
                }
                self?.images.reverse()
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - CollectionViewDelegate & DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("PhotoCollectionViewCell is not found")
        }
        
        let asset = images[indexPath.row]
        
        /* 取得 PHAsset 成 UIImage 資源 */
        let manager = PHImageManager.default()
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 100, height: 100),
                             contentMode: .aspectFit,
                             options: nil) { image, info in
            // 在 UI 執行緒上更新
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        let selectedAsset = images[indexPath.row]
        PHImageManager.default().requestImage(for: selectedAsset,
                                              targetSize: CGSize(width: 300, height: 300),
                                              contentMode: .aspectFit,
                                              options: nil) { [weak self] (image, info) in
            // 取得關於圖片的資訊
            guard let info = info else { return }
            /* 圖片分成 thumbnail 的縮圖和原圖兩種，此處只想取用原圖 */
            let isDegradedImage = info["PHImageResultIsDegradedKey"] as! Bool
            if !isDegradedImage {
                if let image = image {
                    /* ⭐️ TODO: - 使用 PublishSubject 加入圖片 ⭐️ */
                    self?.selectedPhotoSubject.onNext(image)
                    self?.dismiss(animated: true)
                }
            }
        }
        
    }
}
