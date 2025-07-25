//
//  FeedsViewController.swift
//  Where_Are_You
//
//  Created by 오정석 on 30/7/2024.
//

import UIKit
import SwiftUI

class FeedsViewController: UIViewController {
    // MARK: - Properties
    private var feedsView = FeedsView()
    private var noFeedsView = NoDataView()
    var plusOptionButton = CustomOptionButtonView(title: "새 피드 작성", image: nil)
    private var optionsView = MultiCustomOptionsContainerView()
    private var selectedFeed: Feed?
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .lightGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var viewModel: FeedViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupViews()
        setupTableView()
        setupBindings()
        setupActions()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFeeds()
    }
    
    // MARK: - Helpers
    private func setupViewModel() {
        let feedService = FeedService()
        let feedRepository = FeedRepository(feedService: feedService)
        viewModel = FeedViewModel(
            getFeedListUseCase: GetFeedListUseCaseImpl(feedRepository: feedRepository),
            deleteFeedUseCase: DeleteFeedUseCaseImpl(feedRepository: feedRepository),
            postHideFeedUseCase: PostHideFeedUseCaseImpl(feedRepository: feedRepository),
            postBookMarkFeedUseCase: PostBookMarkFeedUseCaseImpl(feedRepository: feedRepository),
            deleteBookMarkFeedUseCase: DeleteBookMarkFeedUseCaseImpl(feedRepository: feedRepository))
    }
    
    private func setupBindings() {
        viewModel.onFeedsDataFetched = { [weak self] in
            DispatchQueue.main.async {
                let isEmpty = self?.viewModel.displayFeedContent.isEmpty ?? true
                self?.feedsView.isHidden = isEmpty
                self?.noFeedsView.isHidden = !isEmpty
                if !isEmpty {
                    self?.feedsView.feedsTableView.reloadData()
                }
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(feedsView)
        view.addSubview(noFeedsView)
        feedsView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        noFeedsView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        noFeedsView.isHidden = true
        plusOptionButton.isHidden = true
        
        view.addSubview(plusOptionButton)
        
        plusOptionButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(LayoutAdapter.shared.scale(value: 9))
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(LayoutAdapter.shared.scale(value: 15))
            make.width.equalTo(LayoutAdapter.shared.scale(value: 160))
            make.height.equalTo(LayoutAdapter.shared.scale(value: 38))
        }
    }
    
    private func setupTableView() {
        if viewModel.displayFeedContent.isEmpty {
            feedsView.isHidden = true
            noFeedsView.isHidden = false
        }
        feedsView.feedsTableView.delegate = self
        feedsView.feedsTableView.dataSource = self
        feedsView.feedsTableView.rowHeight = UITableView.automaticDimension
        feedsView.feedsTableView.sectionHeaderTopPadding = 0
        feedsView.feedsTableView.estimatedRowHeight = LayoutAdapter.shared.scale(value: 498)
        feedsView.feedsTableView.register(FeedsTableViewCell.self, forCellReuseIdentifier: FeedsTableViewCell.identifier)
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white  // 원하는 배경색
        appearance.shadowColor = .clear         // 분리선(쉐도우) 제거

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        view.addGestureRecognizer(tapGesture)
        plusOptionButton.button.addTarget(self, action: #selector(plusOptionButtonTapped), for: .touchUpInside)
    }
    
    func showLoadingFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: feedsView.feedsTableView.bounds.width, height: 50))
        footerView.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        feedsView.feedsTableView.tableFooterView = footerView
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingFooter() {
        loadingIndicator.stopAnimating()
        feedsView.feedsTableView.tableFooterView = nil
    }
    
    private func showOptions(for feed: Feed, at frame: CGRect, isAuthor: Bool) {
        optionsView.removeFromSuperview()
        
        optionsView = FeedOptionsHandler.showOptions(
            in: self.view,
            frame: frame,
            isAuthor: isAuthor,
            isArchive: false,
            feed: feed,
            deleteAction: { self.deleteFeed(feed) },
            editAction: { self.editFeed(feed) },
            hideAction: { self.hideFeed(feed) }
        )
    }
    
    private func deleteFeed(_ feed: Feed) {
        let alert = CustomAlert(
            title: "피드 삭제",
            message: "친구의 피드는 유지되며, 자신의 피드만 영구적으로 삭제됩니다.",
            cancelTitle: "취소",
            actionTitle: "삭제"
        ) { [weak self] in
            self?.viewModel.deleteFeed(feedSeq: feed.feedSeq)
            self?.optionsView.removeFromSuperview()
            self?.feedsView.feedsTableView.reloadData()
        }
        alert.showAlert(on: self)
    }
    
    private func editFeed(_ feed: Feed) {
        print("\(feed.title) 수정")
        optionsView.removeFromSuperview()
        let controller = EditFeedViewController(feed: feed)
        controller.onFeedEdited = { [weak self] in
            self?.viewModel.fetchFeeds()
        }
        pushAndHideTabViewController(controller)
    }
    
    private func hideFeed(_ feed: Feed) {
        let alert = CustomAlert(
            title: "피드 숨김",
            message: "피드를 숨깁니다. 숨긴 피드는 마이페이지에서 복원하거나 영구 삭제할 수 있습니다.",
            cancelTitle: "취소",
            actionTitle: "숨김"
        ) { [weak self] in
            self?.viewModel.hideFeed(feedSeq: feed.feedSeq)
            self?.optionsView.removeFromSuperview()
            self?.feedsView.feedsTableView.reloadData()
        }
        alert.showAlert(on: self)
    }
    
    // MARK: - Selectors
    
    @objc func handleOutsideTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !plusOptionButton.frame.contains(location) {
            plusOptionButton.isHidden = true
        }
        
        if !optionsView.frame.contains(location) {
            optionsView.removeFromSuperview()
        }
    }
    
    @objc func plusOptionButtonTapped() {
        plusOptionButton.isHidden = true
        let controller = AddFeedViewController()
        controller.onFeedCreated = { [weak self] in
            self?.viewModel.fetchFeeds()
        }
        pushAndHideTabViewController(controller)
    }
}

// MARK: - FeedsTableViewCellDelegate

extension FeedsViewController: FeedsTableViewCellDelegate {
    func didTapReadMoreButton() {
    }
    
    func didTapFeedFixButton(feed: Feed, buttonFrame: CGRect) {
        let isAuthor = feed.memberSeq == UserDefaultsManager.shared.getMemberSeq()
        showOptions(for: feed, at: buttonFrame, isAuthor: isAuthor)
    }
    
    func didTapBookmarkButton(feedSeq: Int, isBookMarked: Bool) {
        if isBookMarked {
            viewModel.postFeedBookMark(feedSeq: feedSeq)
        } else {
            viewModel.deleteFeedBookMark(feedSeq: feedSeq)
        }
        // 북마크 상태 변경 후 해당 셀만 업데이트
        if let index = viewModel.displayFeedContent.firstIndex(where: { $0.feedSeq == feedSeq }) {
            let indexPath = IndexPath(row: index, section: 0)
            feedsView.feedsTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func didSelectFeed(feed: Feed) {
        let controller = FeedDetailViewController(feed: feed)
        pushAndHideTabViewController(controller)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FeedsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayFeedContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedsTableViewCell.identifier, for: indexPath) as? FeedsTableViewCell else {
            return UITableViewCell()
        }
        let feed = viewModel.displayFeedContent[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(with: feed)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y // frame영역의 origin에 비교했을때의 content view의 현재 origin 위치
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height // 화면에는 frame만큼 가득 찰 수 있기때문에 frame의 height를 빼준 것

        // 스크롤 할 수 있는 영역보다 더 스크롤된 경우 (하단에서 스크롤이 더 된 경우)
        if maximumOffset < currentOffset {
            showLoadingFooter()
            viewModel.fetchFeeds()
            
            // 예시로 로딩 사라지게
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideLoadingFooter()
            }
        }
    }
}
