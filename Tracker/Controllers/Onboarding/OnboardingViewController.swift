//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.01.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = pages.count
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .ypBlack
        pc.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let blueVC = TemplateViewController(
        backgroundImage: UIImage(named: "onboardingBlue") ?? UIImage(),
        titleLabelText: "Отслеживайте только то, что хотите",
        buttonText: nil
    )
    
    private let redVC = TemplateViewController(
        backgroundImage: UIImage(named: "onboardingRed") ?? UIImage(),
        titleLabelText: "Даже если это не литры воды и йога",
        buttonText: nil
    )
    
    private lazy var pages = [blueVC, redVC]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegates and datasouces
        dataSource = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController as! TemplateViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! TemplateViewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! TemplateViewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}
