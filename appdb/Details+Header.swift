//
//  Details+Header.swift
//  appdb
//
//  Created by ned on 20/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift
import AlamofireImage

class DetailsHeader: DetailsCell {
    
    var name : UILabel!
    var icon : UIImageView!
    var seller : UIButton!
    var tweaked: UILabel?
    var ipadOnly: UILabel?
    var stars: CosmosView?
    var additionalInfo: UILabel?
    
    private var _height = (132~~102) + Featured.size.margin.value
    private var _heightBooks = round((132~~102) * 1.542) + Featured.size.margin.value
    override var height: CGFloat {
        switch type {
            case .ios, .cydia: return _height
            case .books: return _heightBooks
        }
    }
    
    override var identifier: String { return "header" }
    
    convenience init(type: ItemType, content: Object) {
        self.init(style: .default, reuseIdentifier: "header")

        self.type = type
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        separatorInset.left = 10000
        layoutMargins = .zero
        
        //UI
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18~~16)
        name.numberOfLines = type == .books ? 4 : 3
        
        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        
        switch type {
            case .ios: if let app = content as? App {
                name.text = app.name
                if !app.seller.isEmpty {
                    seller = ButtonFactory.createChevronButton(text: app.seller, color: Color.darkGray, size: (15~~13), bold: false)
                }
                icon.layer.cornerRadius = cornerRadius(fromWidth: (130~~100))
                
                if !app.numberOfStars.isZero {
                    stars = buildStars()
                    stars!.rating = app.numberOfStars
                    stars!.text = app.numberOfRating
                } else { stars = nil }
                
                if app.screenshotsIphone.isEmpty && !app.screenshotsIpad.isEmpty {
                    ipadOnly = buildPaddingLabel()
                    ipadOnly!.text = "iPad only".localized().uppercased()
                } else { ipadOnly = nil }
                
                if let url = URL(string: app.image) {
                    icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Filters.getFilter(from: 100),
                                 imageTransition: .crossDissolve(0.2))
                }
            }
            case .cydia: if let cydiaApp = content as? CydiaApp {
                name.text = cydiaApp.name
                if !cydiaApp.developer.isEmpty {
                    seller = ButtonFactory.createChevronButton(text: cydiaApp.developer, color: Color.darkGray, size: (15~~13), bold: false)
                }
                
                if cydiaApp.isTweaked {
                    tweaked  = buildPaddingLabel()
                    tweaked!.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia).uppercased()
                } else { tweaked = nil }
                
                if cydiaApp.screenshotsIphone.isEmpty && !cydiaApp.screenshotsIpad.isEmpty {
                    ipadOnly = buildPaddingLabel()
                    ipadOnly!.text = "iPad only".localized().uppercased()
                } else { ipadOnly = nil }
                
                icon.layer.cornerRadius = cornerRadius(fromWidth: (130~~100))
                if let url = URL(string: cydiaApp.image) {
                    icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Filters.getFilter(from: 100),
                                 imageTransition: .crossDissolve(0.2))
                }
            }
            case .books: if let book = content as? Book {
                name.text = book.name
                if !book.author.isEmpty {
                    seller = ButtonFactory.createChevronButton(text: book.author, color: Color.darkGray, size: (15~~13), bold: false)
                }
                icon.layer.cornerRadius = 0
                
                if !book.numberOfStars.isZero {
                    stars = buildStars()
                    stars!.rating = book.numberOfStars
                    stars!.text = book.numberOfRating
                } else { stars = nil }
                
                if !book.published.isEmpty {
                    additionalInfo = UILabel()
                    additionalInfo!.theme_textColor = Color.darkGray
                    additionalInfo!.font = .systemFont(ofSize: (14~~12))
                    additionalInfo!.numberOfLines = 1
                    additionalInfo!.text = book.published
                    
                    if !book.printLenght.isEmpty {
                        additionalInfo!.text = additionalInfo!.text! + Global.bulletPoint + book.printLenght
                    }
                }
                
                if let url = URL(string: book.image) {
                    icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"),
                                 imageTransition: .crossDissolve(0.2))
                }
            }
        }
        
        contentView.addSubview(name)
        contentView.addSubview(icon)
        if let seller = seller { contentView.addSubview(seller) }
        if let tweaked = tweaked { contentView.addSubview(tweaked) }
        if let stars = stars { contentView.addSubview(stars) }
        if let ipadOnly = ipadOnly { contentView.addSubview(ipadOnly) }
        if let additional = additionalInfo { contentView.addSubview(additional) }
        
        setConstraints()
        
    }

    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            if let seller = seller {
            constrain(name, seller, icon) { name, seller, icon in
                
                icon.width == (130~~100)
                
                switch type {
                    case .ios, .cydia: icon.height == icon.width
                    case .books: icon.height == icon.width * 1.542
                }
                
                icon.left == icon.superview!.left + Featured.size.margin.value
                icon.top == icon.superview!.top + Featured.size.margin.value
                
                name.left == icon.right + (15~~12)
                name.right == name.superview!.right - Featured.size.margin.value
                name.top == icon.top + 3
                
                seller.left == name.left
                seller.top == name.bottom + 3
                seller.right <= seller.superview!.right - Featured.size.margin.value
            }
            }
            
            if let tweaked = tweaked, type == .cydia {
                constrain(tweaked, seller) { tweaked, seller in
                    tweaked.left == seller.left
                    tweaked.right <= tweaked.superview!.right - Featured.size.margin.value
                    tweaked.top == seller.bottom + (7~~6)
                }
            }
            
            if let stars = stars, (type == .ios || type == .books) {
                constrain(stars, seller) { stars, seller in
                    stars.left == seller.left
                    stars.right <= stars.superview!.right - Featured.size.margin.value
                    
                    if type == .books, let additional = additionalInfo {
                        constrain(additional) { additional in
                            additional.left == seller.left
                            additional.right <= additional.superview!.right - Featured.size.margin.value
                            additional.top == seller.bottom + (7~~6)
                            stars.top == additional.bottom + (7~~6)
                        }
                    } else {
                        stars.top == seller.bottom + (7~~6)
                    }
                }
            }
            
            if let ipadOnly = ipadOnly, (type == .ios || type == .cydia) {
                if type == .ios {
                    if let stars = stars {
                        constrain(ipadOnly, stars) { ipadOnly, stars in
                            ipadOnly.left == stars.left
                            ipadOnly.right <= ipadOnly.superview!.right - Featured.size.margin.value
                            ipadOnly.top == stars.bottom + (7~~6)
                            ipadOnly.bottom <= ipadOnly.superview!.bottom
                        }
                    } else {
                        constrain(ipadOnly, seller) { ipadOnly, seller in
                            ipadOnly.left == seller.left
                            ipadOnly.right <= ipadOnly.superview!.right - Featured.size.margin.value
                            ipadOnly.top == seller.bottom + (7~~6)
                        }
                    }
                } else if type == .cydia {
                    if let tweaked = tweaked {
                        constrain(ipadOnly, tweaked) { ipadOnly, tweaked in
                            ipadOnly.left == tweaked.left
                            ipadOnly.right <= ipadOnly.superview!.right - Featured.size.margin.value
                            ipadOnly.top == tweaked.bottom + (7~~6)
                            ipadOnly.bottom <= ipadOnly.superview!.bottom
                        }
                    } else {
                        constrain(ipadOnly, seller) { ipadOnly, seller in
                            ipadOnly.left == seller.left
                            ipadOnly.right <= ipadOnly.superview!.right - Featured.size.margin.value
                            ipadOnly.top == seller.bottom + (7~~6)
                        }
                    }
                }
            }

        }
    }

    private func buildStars() -> CosmosView {
        let stars = CosmosView()
        stars.starSize = 12
        stars.isUserInteractionEnabled = false
        stars.settings.totalStars = 5
        stars.settings.fillMode = .half
        stars.textSize = 11
        stars.textMargin = 2
        stars.starMargin = 0
        return stars
    }
    
    private func buildPaddingLabel() -> PaddingLabel {
        let label = PaddingLabel()
        label.theme_textColor = Color.invertedTitle
        if #available(iOS 8.2, *) {
            label.font = .systemFont(ofSize: 10.0, weight: UIFontWeightSemibold)
        } else {
            label.font = .boldSystemFont(ofSize: 10.0)
        }
        label.layer.backgroundColor = UIColor.gray.cgColor
        label.layer.cornerRadius = 6
        return label
    }

}