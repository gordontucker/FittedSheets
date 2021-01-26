//
//  AddTagsViewController.swift
//  Test
//
//  Created by Jordan Hipwell on 1/4/21.
//

import UIKit
import FittedSheets

class SlideInAnimationBug118ViewController: UIViewController, Demoable {
    static var name: String { "#118 - Sweeping background animation bug" }

    var selectedTags = [String]()
    
    @IBOutlet private var collectionView: UICollectionView!
    
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private let tags = ["Anger","Misery","Sadness","Happiness","Joy","Fear","Anticipation","Surprise","Shame","Envy","Indignation","Courage","Pride","Love","Confusion","Hope","Respect","Caution","Pain","Rage Melon"]
    
    private var contentSizeObserverToken: NSKeyValueObservation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(SlideInAnimationBug118TagCell.self, forCellWithReuseIdentifier: "cell")
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 150, height: 32)
        
        //keep the height of the collection view equal to the height of its content size
        contentSizeObserverToken = collectionView.observe(\UICollectionView.contentSize, options: [.new]) { [weak self] (object, change) in
            guard let selfie = self else { return }
            
            let newHeight = selfie.collectionView.contentSize.height
            if newHeight > 0 && newHeight != selfie.collectionViewHeightConstraint.constant {
                //FIXME: Causes sheet dim overlay to animate strangely.
                // Moving the
                print(selfie.collectionView.contentSize.height)
                UIView.performWithoutAnimation {
                    selfie.collectionViewHeightConstraint.constant = newHeight
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
/*
        // By moving the section from viewDidLoad to the commented out code block below, the bug goes away.
         
        contentSizeObserverToken?.invalidate()
        contentSizeObserverToken = collectionView.observe(\UICollectionView.contentSize, options: [.new]) { [weak self] (object, change) in
            guard let selfie = self else { return }

            let newHeight = selfie.collectionView.contentSize.height
            if newHeight > 0 && newHeight != selfie.collectionViewHeightConstraint.constant {
                //FIXME: Causes sheet dim overlay to animate strangely.
                // Moving the
                print(selfie.collectionView.contentSize.height)
                UIView.performWithoutAnimation {
                    selfie.collectionViewHeightConstraint.constant = newHeight
                }
            }
        }
 */
    }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let addTags = UIStoryboard(name: "SlideInAnimationBug118", bundle: nil).instantiateInitialViewController()!
        
        let sheetController = SheetViewController(
            controller: addTags,
            sizes: [.intrinsic],
            options: SheetOptions(
                pullBarHeight: 0,
                shouldExtendBackground: true,
                useFullScreenMode: false,
                shrinkPresentingViewController: false))
        parent.present(sheetController, animated: true, completion: nil)
    }
}

extension SlideInAnimationBug118ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SlideInAnimationBug118TagCell
        let tag = tags[indexPath.item]
        
        cell.button.setTitle(tag, for: .normal)
        cell.button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return cell
    }
    
}
