// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift

import UIKit

struct R {
  static func validate() {
    storyboard.main.validateImages()
    storyboard.main.validateViewControllers()
  }
  
  struct image {
    static var album: UIImage? { return UIImage(named: "album") }
    static var appIcon: UIImage? { return UIImage(named: "AppIcon") }
    static var check: UIImage? { return UIImage(named: "check") }
    static var close: UIImage? { return UIImage(named: "close") }
    static var filter: UIImage? { return UIImage(named: "filter") }
    static var lensOff: UIImage? { return UIImage(named: "lens-off") }
    static var lensOn: UIImage? { return UIImage(named: "lens-on") }
    static var pause: UIImage? { return UIImage(named: "pause") }
    static var play: UIImage? { return UIImage(named: "play") }
    static var settings: UIImage? { return UIImage(named: "settings") }
    static var tv: UIImage? { return UIImage(named: "tv") }
    static var videocam: UIImage? { return UIImage(named: "videocam") }
  }
  
  struct nib {
    static var launchScreen: _R.nib._LaunchScreen { return _R.nib._LaunchScreen() }
  }
  
  struct reuseIdentifier {
    static var songTableViewCell: ReuseIdentifier<Dubbidson.SongTableViewCell> { return ReuseIdentifier(identifier: "SongTableViewCell") }
    static var videoTableViewCell: ReuseIdentifier<Dubbidson.VideoTableViewCell> { return ReuseIdentifier(identifier: "VideoTableViewCell") }
  }
  
  struct segue {
    static var selectFilter: String { return "selectFilter" }
    static var selectSong: String { return "selectSong" }
    static var watchVideo: String { return "watchVideo" }
  }
  
  struct storyboard {
    struct main {
      static var initialViewController: UITabBarController? { return instance.instantiateInitialViewController() as? UITabBarController }
      static var instance: UIStoryboard { return UIStoryboard(name: "Main", bundle: nil) }
      
      static func validateImages() {
        assert(UIImage(named: "album") != nil, "[R.swift] Image named 'album' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "check") != nil, "[R.swift] Image named 'check' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "close") != nil, "[R.swift] Image named 'close' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "filter") != nil, "[R.swift] Image named 'filter' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "lens-off") != nil, "[R.swift] Image named 'lens-off' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "play") != nil, "[R.swift] Image named 'play' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "settings") != nil, "[R.swift] Image named 'settings' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "tv") != nil, "[R.swift] Image named 'tv' is used in storyboard 'Main', but couldn't be loaded.")
        assert(UIImage(named: "videocam") != nil, "[R.swift] Image named 'videocam' is used in storyboard 'Main', but couldn't be loaded.")
      }
      
      static func validateViewControllers() {
        
      }
    }
  }
}

struct _R {
  struct nib {
    struct _LaunchScreen: NibResource {
      var instance: UINib { return UINib.init(nibName: "LaunchScreen", bundle: nil) }
      
      func firstView(ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]?) -> UIView? {
        return instantiateWithOwner(ownerOrNil, options: optionsOrNil)[0] as? UIView
      }
      
      func instantiateWithOwner(ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]?) -> [AnyObject] {
        return instance.instantiateWithOwner(ownerOrNil, options: optionsOrNil)
      }
    }
  }
}

struct ReuseIdentifier<T>: Printable {
  let identifier: String
  
  var description: String { return identifier }
}

protocol NibResource {
  var instance: UINib { get }
}

protocol Reusable {
  typealias T
  
  var reuseIdentifier: ReuseIdentifier<T> { get }
}

extension UITableView {
  func dequeueReusableCellWithIdentifier<T : UITableViewCell>(identifier: ReuseIdentifier<T>, forIndexPath indexPath: NSIndexPath?) -> T? {
    if let indexPath = indexPath {
      return dequeueReusableCellWithIdentifier(identifier.identifier, forIndexPath: indexPath) as? T
    }
    return dequeueReusableCellWithIdentifier(identifier.identifier) as? T
  }
  
  func dequeueReusableCellWithIdentifier<T : UITableViewCell>(identifier: ReuseIdentifier<T>) -> T? {
    return dequeueReusableCellWithIdentifier(identifier.identifier) as? T
  }
  
  func dequeueReusableHeaderFooterViewWithIdentifier<T : UITableViewHeaderFooterView>(identifier: ReuseIdentifier<T>) -> T? {
    return dequeueReusableHeaderFooterViewWithIdentifier(identifier.identifier) as? T
  }
  
  func registerNib<T: NibResource where T: Reusable, T.T: UITableViewCell>(nibResource: T) {
    registerNib(nibResource.instance, forCellReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }
  
  func registerNibForHeaderFooterView<T: NibResource where T: Reusable, T.T: UIView>(nibResource: T) {
    registerNib(nibResource.instance, forHeaderFooterViewReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }
  
  func registerNibs<T: NibResource where T: Reusable, T.T: UITableViewCell>(nibResources: [T]) {
    nibResources.map(registerNib)
  }
}

extension UICollectionView {
  func dequeueReusableCellWithReuseIdentifier<T: UICollectionViewCell>(identifier: ReuseIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> T? {
    return dequeueReusableCellWithReuseIdentifier(identifier.identifier, forIndexPath: indexPath) as? T
  }
  
  func dequeueReusableSupplementaryViewOfKind<T: UICollectionReusableView>(elementKind: String, withReuseIdentifier identifier: ReuseIdentifier<T>, forIndexPath indexPath: NSIndexPath) -> T? {
    return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier.identifier, forIndexPath: indexPath) as? T
  }
  
  func registerNib<T: NibResource where T: Reusable, T.T: UICollectionViewCell>(nibResource: T) {
    registerNib(nibResource.instance, forCellWithReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }
  
  func registerNib<T: NibResource where T: Reusable, T.T: UICollectionReusableView>(nibResource: T, forSupplementaryViewOfKind kind: String) {
    registerNib(nibResource.instance, forSupplementaryViewOfKind: kind, withReuseIdentifier: nibResource.reuseIdentifier.identifier)
  }
  
  func registerNibs<T: NibResource where T: Reusable, T.T: UICollectionViewCell>(nibResources: [T]) {
    nibResources.map(registerNib)
  }
  
  func registerNibs<T: NibResource where T: Reusable, T.T: UICollectionReusableView>(nibResources: [T], forSupplementaryViewOfKind kind: String) {
    nibResources.map { self.registerNib($0, forSupplementaryViewOfKind: kind) }
  }
}