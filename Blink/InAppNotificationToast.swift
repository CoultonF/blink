////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

import UIKit

class InAppNotificationToast: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 14)
    label.textColor = .white
    label.numberOfLines = 1
    return label
  }()

  private let bodyLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 13)
    label.textColor = UIColor.white.withAlphaComponent(0.85)
    label.numberOfLines = 2
    return label
  }()

  private let stackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 2
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private var dismissTimer: Timer?

  init(title: String, body: String) {
    super.init(frame: .zero)

    titleLabel.text = title
    bodyLabel.text = body
    bodyLabel.isHidden = body.isEmpty

    backgroundColor = UIColor.black.withAlphaComponent(0.85)
    layer.cornerRadius = 12
    clipsToBounds = true
    translatesAutoresizingMaskIntoConstraints = false

    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(bodyLabel)
    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])

    let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
    addGestureRecognizer(tap)

    // Don't steal focus from the terminal
    isUserInteractionEnabled = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var canBecomeFirstResponder: Bool { false }

  func show(in parentView: UIView) {
    parentView.addSubview(self)

    let safeTop = parentView.safeAreaInsets.top

    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
      widthAnchor.constraint(lessThanOrEqualToConstant: 400),
      widthAnchor.constraint(lessThanOrEqualTo: parentView.widthAnchor, constant: -32),
      topAnchor.constraint(equalTo: parentView.topAnchor, constant: safeTop + 8),
    ])

    alpha = 0
    transform = CGAffineTransform(translationX: 0, y: -20)

    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
      self.alpha = 1
      self.transform = .identity
    }

    dismissTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
      self?.dismiss()
    }
  }

  @objc func dismiss() {
    dismissTimer?.invalidate()
    dismissTimer = nil

    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
      self.alpha = 0
      self.transform = CGAffineTransform(translationX: 0, y: -20)
    }) { _ in
      self.removeFromSuperview()
    }
  }
}
