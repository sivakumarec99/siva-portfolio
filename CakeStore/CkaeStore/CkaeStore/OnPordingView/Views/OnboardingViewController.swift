//
//  OnboardingViewController.swift
//  CakeStore
//
//  Created by JIDTP1408 on 20/03/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(imageName: "slide1", title: "All your favorites", description: "Get all your loved foods in one once place,\nyou just place the orer we do the rest"),
        OnboardingSlide(imageName: "slide2", title: "All your favorites", description: "Get all your loved foods in one once place,/nyou just place the orer we do the rest."),
        OnboardingSlide(imageName: "slide3", title: "Order from choosen chef", description: "Get all your loved foods in one once place,/nyou just place the orer we do the rest"),
        OnboardingSlide(imageName: "slide4", title: "Get Started", description: "Get all your loved foods in one once place,/nyou just place the orer we do the rest")
    ]
    
    private var pageViewController: UIPageViewController!
    private var currentIndex = 0
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .blue
        pc.pageIndicatorTintColor = .lightGray
        return pc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupPageViewController()
        setupButtons()
        setupPageControl()
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstVC = viewControllerForIndex(0) {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupButtons() {
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.numberOfPages = slides.count
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20)
        ])
    }
    
    @objc private func nextButtonTapped() {
        if currentIndex < slides.count - 1 {
            currentIndex += 1
            let nextVC = viewControllerForIndex(currentIndex)
            pageViewController.setViewControllers([nextVC!], direction: .forward, animated: true, completion: nil)
            pageControl.currentPage = currentIndex
        } else {
            // Save flag in UserDefaults when onboarding is finished
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            UserDefaults.standard.synchronize()
            
            // Navigate to MainViewController
            let mainVC = UINavigationController(rootViewController: ViewController())
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true, completion: nil)
        }
    }
    @objc private func skipButtonTapped() {
        currentIndex = slides.count - 1
        let lastVC = viewControllerForIndex(currentIndex)
        pageViewController.setViewControllers([lastVC!], direction: .forward, animated: true, completion: nil)
        pageControl.currentPage = currentIndex
    }
    
    private func viewControllerForIndex(_ index: Int) -> OnboardingSlideViewController? {
        guard index >= 0 && index < slides.count else { return nil }
        let slideVC = OnboardingSlideViewController()
        slideVC.slide = slides[index]
        return slideVC
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let slideVC = viewController as? OnboardingSlideViewController,
              let index = slides.firstIndex(where: { $0.title == slideVC.slide?.title }),
              index > 0 else { return nil }
        return viewControllerForIndex(index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let slideVC = viewController as? OnboardingSlideViewController,
              let index = slides.firstIndex(where: { $0.title == slideVC.slide?.title }),
              index < slides.count - 1 else { return nil }
        return viewControllerForIndex(index + 1)
    }
}
