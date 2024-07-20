//
//  MainHomeViewController.swift
//  Where_Are_You
//
//  Created by 오정석 on 8/7/2024.
//

import UIKit

class MainHomeViewController: UIViewController {
    private var mainHomeView: MainHomeView!
    private var bannerViewController: BannerViewController!
    private var scheduleViewController: ScheduleViewController!
    private var feedTableViewController: FeedTableViewController!
    
    override func loadView() {
        mainHomeView = MainHomeView()
        view = mainHomeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupBindings()
        setupActions()
    }
    
    func setupViewControllers() {
        // 서브뷰 컨트롤러 초기화
        bannerViewController = BannerViewController()
        scheduleViewController = ScheduleViewController()
        feedTableViewController = FeedTableViewController()
        
        // 서브뷰 컨트롤러를 자식 컨트롤러로 추가
        addChild(bannerViewController)
        addChild(scheduleViewController)
        addChild(feedTableViewController)
        
        // 서브뷰 컨트롤러의 뷰를 MainHomeView에 추가
        mainHomeView.bannerView.addSubview(bannerViewController.view)
        mainHomeView.scheduleView.addSubview(scheduleViewController.view)
        mainHomeView.feedTableView.addSubview(feedTableViewController.view)
        
        // 서브뷰 컨트롤러의 뷰가 부모 컨트롤러에 추가되었음을 알림
        bannerViewController.didMove(toParent: self)
        scheduleViewController.didMove(toParent: self)
        feedTableViewController.didMove(toParent: self)
        
        // 서브뷰 컨트롤러 뷰의 제약 조건 설정
        bannerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scheduleViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        feedTableViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        bannerViewController.viewModel.onBannerDataFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.bannerViewController.bannerView.collectionView.reloadData()
                self?.bannerViewController.bannerView.pageControl.numberOfPages = self?.bannerViewController.viewModel.getBannerImages().count ?? 0
            }
        }
        
        scheduleViewController.viewModel.onScheduleDataFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.scheduleViewController.scheduleView.collectionView.reloadData()
            }
        }
        
        feedTableViewController.viewModel.onFeedsDataFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.feedTableViewController.feedTableView.tableView.reloadData()
            }
        }
    }
    
    private func setupActions() {
        mainHomeView.reminderButton.addTarget(self, action: #selector(reminderButtonTapped), for: .touchUpInside)
    }
    
    // 추후 피드 메인 컨트롤러 만들어야 함
    @objc private func reminderButtonTapped() {
        //        let feedViewController = FeedViewController()
        //        navigationController?.pushViewController(feedViewController, animated: true)
    }
}