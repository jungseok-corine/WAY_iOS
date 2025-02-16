//
//  ScheduleDropDownCell.swift
//  Where_Are_You
//
//  Created by 오정석 on 18/8/2024.
//

import UIKit

class ScheduleDropDownCell: UITableViewCell {
    
    static let identifier = "ScheduleDropDownCell"
    
    let titleLabel = CustomLabel(UILabel_NotoSans: .medium, text: "", textColor: .black44, fontSize: LayoutAdapter.shared.scale(value: 16))
    
    let locationLabel = CustomLabel(UILabel_NotoSans: .medium, text: "", textColor: .color153, fontSize: LayoutAdapter.shared.scale(value: 14))
   
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViewComponents()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViewComponents() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(checkmarkImageView)
        
        checkmarkImageView.isHidden = true
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(LayoutAdapter.shared.scale(value: 6))
            make.leading.equalToSuperview().inset(LayoutAdapter.shared.scale(value: 6))
            make.trailing.equalTo(checkmarkImageView.snp.leading).offset(LayoutAdapter.shared.scale(value: 6))
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(LayoutAdapter.shared.scale(value: 2))
            make.bottom.equalToSuperview().inset(LayoutAdapter.shared.scale(value: 8))
            make.leading.equalTo(titleLabel)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(LayoutAdapter.shared.scale(value: 19))
            make.width.equalTo(LayoutAdapter.shared.scale(value: 15.28))
        }
    }
    
    func configure(with schedule: ScheduleContent) {
        titleLabel.text = schedule.title
        locationLabel.text = schedule.location
        checkmarkImageView.isHidden = !schedule.feedExists
    }
}
