import UIKit
import SpriteKit

public class GameApp {
    
    var window: UIWindow?
    
    public init(controller: UIWindow?) {
        self.window = controller
    }
    
    public func showController() {
        GameApp.registerFonts()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle(for: GameApp.self))
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    public static func storyboardProvider(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: Bundle(for: GameApp.self))
    }
    
    public static func bundleProvider() -> Bundle{
        return Bundle(for: GameApp.self)
    }
    
    public static func imageProvider(named: String) -> UIImage? {
        return UIImage(named: named, in: GameApp.bundleProvider(), with: nil)
    }
    
    public static func textureProvider(imageNamed: String) -> SKTexture {
        let image = imageProvider(named: imageNamed)
        return SKTexture(image: image!)
    }
    
    public static func registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
    
    public static func registerFonts() {
        let fontsTTF = GameApp.bundleProvider().urls(forResourcesWithExtension: "ttf", subdirectory: nil)
        let fontsOTF = GameApp.bundleProvider().urls(forResourcesWithExtension: "otf", subdirectory: nil)
        fontsTTF?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
        fontsOTF?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
    }
    
    public static func recursivePaths(forResourcesWithExtension: String) -> [URL] {
        let enumerator = FileManager.default.enumerator(atPath: GameApp.bundleProvider().bundlePath)
        var filePaths = [URL]()
        while let filePath = enumerator?.nextObject() as? String {
            if #available(iOS 16, *) {
                if URL(filePath: filePath).pathExtension == forResourcesWithExtension {
                    filePaths.append(GameApp.bundleProvider().bundleURL.appending(path: filePath))
                }
            } else {
                if URL(fileURLWithPath: filePath).pathExtension == forResourcesWithExtension {
                    filePaths.append(GameApp.bundleProvider().bundleURL.appendingPathComponent(filePath))
                }
            }
        }
        return filePaths
    }
}

