//
// Copyright 2014 Scott Logic
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class ViewController: UIViewController {
  
  var videoFilter: CoreImageVideoFilter?
  var detector: CIDetector?
  var currentFilteredImage: CIImage?
  
    @IBOutlet weak var imgView: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
//    // Create the video filter
//    videoFilter = CoreImageVideoFilter(superview: view, applyFilterCallback: nil)
//    
//    // Simulate a tap on the mode selector to start the process
//    handleDetectorSelectionChange(0)
    
    //following is the Static Image Detection Code
    detector = prepareRectangleDetector()
    let uiImage = self.imgView.image
    let ciImage = CIImage.init(image: uiImage!)
    performRectangleDetection(ciImage!)
  }
  
  func handleDetectorSelectionChange(_ selectedIndex: Int) {
    if let videoFilter = videoFilter {
      videoFilter.stopFiltering()
      switch selectedIndex {
      case 0:
        detector = prepareRectangleDetector()
        videoFilter.applyFilter = {
          image in
          self.performRectangleDetection(image)
          return self.currentFilteredImage
        }
      default:
        videoFilter.applyFilter = nil
      }
      videoFilter.startFiltering()
    }
  }
  
  
  //MARK: Utility methods
  func performRectangleDetection(_ image: CIImage) -> Void {
    if let detector = detector {
      // Get the detections
      let features = detector.features(in: image)
        print("printing the count \(features.count)")
      for feature in features as! [CIRectangleFeature] {
        self.currentFilteredImage = self.drawHighlightOverlayForPoints(image, topLeft: feature.topLeft, topRight: feature.topRight,
                bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
        print("topLeft.y \(feature.topLeft.y)")
        print("bottomLeft.y \(feature.bottomLeft.y)")
        print("topLeft.x \(feature.topLeft.x)")
        print("topRight.x \(feature.topRight.x)")
        print("Height \(feature.topLeft.y - feature.bottomLeft.y)")
        print("Width \(feature.topRight.x - feature.topLeft.x)")
      }
    }
  }
   
  func prepareRectangleDetector() -> CIDetector {
    if #available(iOS 10.0, *) {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorAspectRatio: 1, CIDetectorMaxFeatureCount: 3]
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    } else {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorAspectRatio: 1]
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
  }
  
  func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                     bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
    var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
    overlay = overlay.cropping(to: image.extent)
    overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
      withInputParameters: [
        "inputExtent": CIVector(cgRect: image.extent),
        "inputTopLeft": CIVector(cgPoint: topLeft),
        "inputTopRight": CIVector(cgPoint: topRight),
        "inputBottomLeft": CIVector(cgPoint: bottomLeft),
        "inputBottomRight": CIVector(cgPoint: bottomRight)
      ])
    let frontCiImage = overlay.compositingOverImage(image)
    let frontImg = UIImage.init(ciImage: frontCiImage)
    let frontImgView  = UIImageView.init(image: frontImg)
    self.imgView.addSubview(frontImgView)
    return frontCiImage //overlay.compositingOverImage(image)
  }
}

