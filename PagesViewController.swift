//
//  GamePagesViewController.swift
//  
//
//  Created by Jeanne Luning Prak on 7/29/16.
//
//

import UIKit

class PagesViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var counter = 0
    var pages = [ArticleViewController()]
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        let firstVC = pages[0]
        setViewControllers([firstVC],
                           direction: .Forward,
                           animated: false,
                           completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let nextVC = pages[0]
        nextVC.loadCurrentArticle(ArticleSource.allArticles[ArticleSource.articleIndex + 1] as! Article)
        return nextVC
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed && finished {
            ArticleSource.articleIndex += 1
        }
    }
    
}
