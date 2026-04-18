// OnboardingViewController.swift
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingDidFinish()
}

class OnboardingViewController: UIViewController {
    
    // MARK: - UI Elements
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        // Активная точка: КРАСНАЯ
        pc.currentPageIndicatorTintColor = .ypBlackDay
        pc.pageIndicatorTintColor = .darkGray
        pc.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .ypBlackDay
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var pages: [OnboardingContentViewController] = []
    weak var delegate: OnboardingViewControllerDelegate?
    
    private var currentIndex = 0 {
        didSet {
            pageControl.currentPage = currentIndex
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupPages() {
        let onboardingPages = [
            OnboardingPage(
                title: "Отслеживайте только то, что хотите",
                imageName: "onboarding1",
                backgroundColor: .white
            ),
            OnboardingPage(
                title: "Даже если это не литры воды и йога",
                imageName: "onboarding2",
                backgroundColor: .white
            )
        ]
        
        pages = onboardingPages.map { page in
            let vc = OnboardingContentViewController()
            vc.page = page
            return vc
        }
    }
    
    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true)
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(startButton)
        
        // Учитываем увеличенный масштаб PageControl в отступах (scale 1.5)
        NSLayoutConstraint.activate([
            // Поднимаем PageControl чуть выше, так как он стал крупнее
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -164),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            
        ])
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func startButtonTapped() {
        delegate?.onboardingDidFinish()
    }
    
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingContentViewController),
              index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingContentViewController),
              index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return
        }
        self.currentIndex = currentIndex
    }
}
