//
//  RatingView.swift
//  FakeNFT
//
//  Created by Simon Butenko on 16.12.2024.
//

import SnapKit
import Then
import UIKit

class RatingView: UIView {
    // MARK: Constants
    enum Constants {
        static let maximumRating = 5
    }

    // MARK: - Properties
    private var currentRating: Int = 0 {
        didSet {
            updateStars()
        }
    }

    private var starViews: [UIImageView] = []

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        for index in 1...Constants.maximumRating {
            let starView = UIImageView().then {
                $0.tag = index
                $0.image = .inactiveStar
            }
            starViews.append(starView)
            addSubview(starView)

            starView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 12, height: 12))
                if index == 1 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(starViews[index - 2].snp.trailing).offset(2)
                }
                if index == Constants.maximumRating {
                    make.trailing.equalToSuperview()
                }
            }
        }
    }

    // MARK: - Update UI
    private func updateStars() {
        for starView in starViews {
            if starView.tag <= currentRating {
                starView.image = .activeStar
            } else {
                starView.image = .inactiveStar
            }
        }
    }

    // MARK: - Public Methods
    func setRating(_ rating: Int) {
        currentRating = min(max(rating, 0), Constants.maximumRating)
    }
}
