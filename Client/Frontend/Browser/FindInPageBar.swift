/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

protocol FindInPageBarDelegate: class {
    func findInPage(findInPage: FindInPageBar, didTextChange text: String)
    func findInPage(findInPage: FindInPageBar, didFindPreviousWithText text: String)
    func findInPage(findInPage: FindInPageBar, didFindNextWithText text: String)
    func findInPageDidPressClose(findInPage: FindInPageBar)
}

class FindInPageBar: UIView {
    weak var delegate: FindInPageBarDelegate?
    private let searchText = UITextField()
    private let matchCountView = UILabel()
    private let previousButton = UIButton()
    private let nextButton = UIButton()

    var currentResult = 0 {
        didSet {
            matchCountView.text = "\(currentResult)/\(totalResults)"
        }
    }

    var totalResults = 0 {
        didSet {
            matchCountView.text = "\(currentResult)/\(totalResults)"
            previousButton.enabled = totalResults > 1
            nextButton.enabled = previousButton.enabled
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()

        searchText.addTarget(self, action: "didTextChange:", forControlEvents: UIControlEvents.EditingChanged)
        searchText.textColor = UIColor(rgb: 0xe66000)
        searchText.font = UIConstants.DefaultChromeFont
        searchText.autocapitalizationType = UITextAutocapitalizationType.None
        searchText.autocorrectionType = UITextAutocorrectionType.No
        addSubview(searchText)

        matchCountView.textColor = UIColor.lightGrayColor()
        matchCountView.font = UIConstants.DefaultChromeFont
        matchCountView.hidden = true
        addSubview(matchCountView)

        previousButton.setImage(UIImage(named: "find_previous"), forState: UIControlState.Normal)
        previousButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        previousButton.accessibilityLabel = NSLocalizedString("Previous in-page result", tableName: "FindInPage", comment: "Accessibility label for previous result button in Find in Page Toolbar.")
        previousButton.addTarget(self, action: "didFindPrevious:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(previousButton)

        nextButton.setImage(UIImage(named: "find_next"), forState: UIControlState.Normal)
        nextButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        nextButton.accessibilityLabel = NSLocalizedString("Next in-page result", tableName: "FindInPage", comment: "Accessibility label for next result button in Find in Page Toolbar.")
        nextButton.addTarget(self, action: "didFindNext:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(nextButton)

        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "find_close"), forState: UIControlState.Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        closeButton.accessibilityLabel = NSLocalizedString("Done", tableName: "FindInPage", comment: "Done button in Find in Page Toolbar.")
        closeButton.addTarget(self, action: "didPressClose:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(closeButton)

        let topBorder = UIView()
        topBorder.backgroundColor = UIColor(rgb: 0xEEEEEE)
        addSubview(topBorder)

        searchText.snp_makeConstraints { make in
            make.leading.equalTo(self).offset(8)
            make.top.bottom.equalTo(self)
        }

        matchCountView.snp_makeConstraints { make in
            make.leading.equalTo(searchText.snp_trailing)
            make.centerY.equalTo(self)
        }

        previousButton.snp_makeConstraints { make in
            make.leading.equalTo(matchCountView.snp_trailing)
            make.size.equalTo(self.snp_height)
            make.centerY.equalTo(self)
        }

        nextButton.snp_makeConstraints { make in
            make.leading.equalTo(previousButton.snp_trailing)
            make.size.equalTo(self.snp_height)
            make.centerY.equalTo(self)
        }

        closeButton.snp_makeConstraints { make in
            make.leading.equalTo(nextButton.snp_trailing)
            make.size.equalTo(self.snp_height)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self)
        }

        topBorder.snp_makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.top.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        searchText.becomeFirstResponder()
        return super.becomeFirstResponder()
    }

    @objc func didFindPrevious(sender: UIButton) {
        delegate?.findInPage(self, didFindPreviousWithText: searchText.text ?? "")
    }

    @objc func didFindNext(sender: UIButton) {
        delegate?.findInPage(self, didFindNextWithText: searchText.text ?? "")
    }

    @objc func didTextChange(sender: UITextField) {
        matchCountView.hidden = searchText.text?.isEmpty ?? true
        delegate?.findInPage(self, didTextChange: searchText.text ?? "")
    }

    @objc func didPressClose(sender: UIButton) {
        delegate?.findInPageDidPressClose(self)
    }
}