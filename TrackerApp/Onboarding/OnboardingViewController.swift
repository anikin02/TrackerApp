//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Данил on 16/11/2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
  // MARK: - Private Properties
  private let trackersScreenButton: UIButton = .init()
  private let pageControl: UIPageControl = .init()
  
  private lazy var slideViewControllers: [UIViewController] = {
    let firstSlide = SlideViewController()
    let firstOnboardingSlideTitle = NSLocalizedString("firstOnboardingSlideTitle", comment: "")
    firstSlide.configure(title: firstOnboardingSlideTitle, cover: UIImage(resource: .firstSlide))
    
    let secondOnboardingSlideTitle = NSLocalizedString("secondOnboardingSlideTitle", comment: "")
    let secondSlide = SlideViewController()
    secondSlide.configure(title: secondOnboardingSlideTitle, cover: UIImage(resource: .secondSlide))
    
    return [firstSlide, secondSlide]
  }()
  
  // MARK: - Init
  init() {
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AnalyticsService.shared.sendReport(event: .open, screen: .onboarding)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    AnalyticsService.shared.sendReport(event: .close, screen: .onboarding)
  }
  
  // MARK: - Private Methods
  private func configureUI() {
    configurePages()
    configureTrackersScreenButton()
    configurePageControl()
  }
  
  private func configurePages() {
    dataSource = self
    delegate = self
    
    if let first = slideViewControllers.first {
      setViewControllers([first], direction: .forward, animated: true)
    }
  }
  
  private func configureTrackersScreenButton() {
    trackersScreenButton.translatesAutoresizingMaskIntoConstraints = false
    let buttonOnboardingTitle = NSLocalizedString("buttonOnboardingTitle", comment: "")
    trackersScreenButton.setTitle(buttonOnboardingTitle, for: .normal)
    trackersScreenButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    trackersScreenButton.setTitleColor(.whiteYP, for: .normal)
    trackersScreenButton.backgroundColor = .blackYP
    trackersScreenButton.layer.cornerRadius = 16
    trackersScreenButton.layer.masksToBounds = true
    trackersScreenButton.addTarget(self, action: #selector(didTapTrackersScreenButton), for: .touchUpInside)
    
    view.addSubview(trackersScreenButton)
    
    NSLayoutConstraint.activate([
      trackersScreenButton.heightAnchor.constraint(equalToConstant: 60),
      trackersScreenButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      trackersScreenButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      trackersScreenButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
    ])
  }
  
  private func configurePageControl() {
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    pageControl.numberOfPages = slideViewControllers.count
    pageControl.currentPage = 0
    
    pageControl.currentPageIndicatorTintColor = .blackYP
    pageControl.pageIndicatorTintColor = .blackYP.withAlphaComponent(0.3)
    
    view.addSubview(pageControl)
    
    NSLayoutConstraint.activate([
      pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      pageControl.bottomAnchor.constraint(equalTo: trackersScreenButton.topAnchor, constant: -24)
    ])
  }
  
  // MARK: - Actions
  @objc private func didTapTrackersScreenButton() {
    FirstLaunchService.shared.hasLaunchedBefore = true
    
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    
    let tabBarController = TabBarController()
    
    window?.rootViewController = tabBarController
  }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = slideViewControllers.firstIndex(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else {
      return nil
    }
    
    return slideViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = slideViewControllers.firstIndex(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    
    guard nextIndex < slideViewControllers.count else {
      return nil
    }
    
    return slideViewControllers[nextIndex]
  }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if let currentViewController = pageViewController.viewControllers?.first,
       let currentIndex = slideViewControllers.firstIndex(of: currentViewController) {
      
      pageControl.currentPage = currentIndex
    }
  }
}
