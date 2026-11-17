//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Данил on 16/11/2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
  private let trackersScreenButton: UIButton = .init()
  private let pageControl: UIPageControl = .init()
  
  private lazy var slideViews: [UIViewController] = {
    let firstSlide = SlideViewController()
    firstSlide.configureView(title: "Отслеживайте только то, что хотите", cover: UIImage(resource: .firstSlide))
    
    let secondSlide = SlideViewController()
    secondSlide.configureView(title: "Даже если это не литры воды и йога", cover: UIImage(resource: .secondSlide))
    
    return [firstSlide, secondSlide]
  }()
  
  // MARK: - Init
  init() {
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
  }
  
  private func configureUI() {
    configurePages()
    configureTrackersScreenButton()
    configurePageControl()
  }
  
  private func configurePages() {
    dataSource = self
    delegate = self
    
    if let first = slideViews.first {
      setViewControllers([first], direction: .forward, animated: true)
    }
  }
  
  private func configureTrackersScreenButton() {
    trackersScreenButton.translatesAutoresizingMaskIntoConstraints = false
    trackersScreenButton.setTitle("Вот это технологии!", for: .normal)
    trackersScreenButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    trackersScreenButton.titleLabel?.textColor = .whiteYP
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
    pageControl.numberOfPages = slideViews.count
    pageControl.currentPage = 0
    
    pageControl.currentPageIndicatorTintColor = .blackYP
    pageControl.pageIndicatorTintColor = .blackYP.withAlphaComponent(0.3)
    
    view.addSubview(pageControl)
    
    NSLayoutConstraint.activate([
      pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      pageControl.bottomAnchor.constraint(equalTo: trackersScreenButton.topAnchor, constant: -24)
    ])
  }
  
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

extension OnboardingViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = slideViews.firstIndex(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else {
      return nil
    }
    
    return slideViews[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = slideViews.firstIndex(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    
    guard nextIndex < slideViews.count else {
      return nil
    }
    
    return slideViews[nextIndex]
  }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if let currentViewController = pageViewController.viewControllers?.first,
       let currentIndex = slideViews.firstIndex(of: currentViewController) {
      
      pageControl.currentPage = currentIndex
    }
  }
}
