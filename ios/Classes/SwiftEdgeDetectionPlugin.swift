// import Flutter
// import UIKit
// import WeScan

// public class SwiftEdgeDetectionPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
    
//     public static func register(with registrar: FlutterPluginRegistrar) {
//         let channel = FlutterMethodChannel(name: "edge_detection", binaryMessenger: registrar.messenger())
//         let instance = SwiftEdgeDetectionPlugin()
//         registrar.addMethodCallDelegate(instance, channel: channel)
//         registrar.addApplicationDelegate(instance)
//     }
    
//     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
//         if (call.method == "edge_detect")
//         {
//             if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
//                 let destinationViewController = HomeViewController()
//                 destinationViewController._result = result
//                 viewController.present(destinationViewController,animated: true,completion: nil);
//             }
//         }
//         if (call.method == "edge_detect_gallery")
//         {
//             if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
//                 let destinationViewController = HomeViewController()
//                 destinationViewController._result = result
//                 destinationViewController.selectPhoto();
//             }
//         }
//     }
// }
import WeScan
import Flutter
import UIKit

public class SwiftEdgeDetectionPlugin: NSObject, FlutterPlugin {
    
    var rootViewController: UIViewController?
    var result: FlutterResult?
    
    
    public override init() {
        super.init()
        rootViewController =
            (UIApplication.shared.delegate?.window??.rootViewController)!;
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "edge_detection", binaryMessenger: registrar.messenger())
        let instance = SwiftEdgeDetectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        typealias channelMethod = () -> ()
        var channelMethods : Dictionary = [String : channelMethod]()
        channelMethods["edge_detect"] = camera
        channelMethods["edge_detect_gallery"] = gallery
        if(!channelMethods.keys.contains(call.method)){
            result(FlutterMethodNotImplemented)
        }
        
        channelMethods[call.method]!();
        
    }
    
    private func camera() {
        let scannerViewController: ImageScannerController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        scannerViewController.modalPresentationStyle = .fullScreen

        if #available(iOS 13.0, *) {
            scannerViewController.overrideUserInterfaceStyle = .dark
        }

        rootViewController?.present(scannerViewController, animated:true, completion:nil)
    }
    
    func gallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen

        rootViewController?.present(imagePicker, animated: true)
    }
}

extension SwiftEdgeDetectionPlugin : ImageScannerControllerDelegate{

    private func saveImage(image: UIImage) -> String? {
        
        guard let documentsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { return nil }
        
        let fileName = uniqueFileNameWithExtention(fileExtension: "jpg")
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.2) else { return nil }

        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch let error {
            print("error saving file with error", error)
            return nil
        }
        
    }
    

     private func uniqueFileNameWithExtention(fileExtension: String) -> String {
        let uniqueString: String = ProcessInfo.processInfo.globallyUniqueString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmsss"
        let dateString: String = formatter.string(from: Date())
        let uniqueName: String = "\(uniqueString)_\(dateString)"
        if fileExtension.count > 0 {
            let fileName: String = "\(uniqueName).\(fileExtension)"
            return fileName
        }
        
        return uniqueName
    }
    
            private func getScannedFile(results: ImageScannerResults) -> String? {
        var path: String?
        if(results.doesUserPreferEnhancedScan && results.enhancedScan != nil){
            path = saveImage(image: results.enhancedScan!.image)
            return path
        }
        path = saveImage(image: results.croppedScan.image)
        return path
    }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true)
        let path = getScannedFile(results: results)
        result?(path)
    }
    
    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }
    
    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        scanner.dismiss(animated: true)
    }
}

extension SwiftEdgeDetectionPlugin: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        pikedCamera(image: image)
    }
    
    private func pikedCamera(image: UIImage? = nil){
        let scannerViewController: ImageScannerController = ImageScannerController(image:image)
        scannerViewController.imageScannerDelegate = self
        scannerViewController.modalPresentationStyle = .fullScreen

        if #available(iOS 13.0, *) {
            scannerViewController.overrideUserInterfaceStyle = .dark
        }
        rootViewController?.present(scannerViewController, animated:true, completion:nil)
    }
}