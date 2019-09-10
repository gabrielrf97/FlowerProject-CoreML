//
//  ViewController.swift
//  FlowerApp
//
//  Created by Gabriel on 09/09/19.
//  Copyright © 2019 gabrielrodrigues. All rights reserved.
//

import UIKit
import Vision
import Alamofire
import SVProgressHUD
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flowerDescription: UITextView!
    
    var imageHolder : UIImage?
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePicker()
        configurePictureImageView()
        self.navigationController?.isNavigationBarHidden = true
        showImagePicker()
    }
    
    @IBAction func newPressed(_ sender: Any) {
        showImagePicker()
    }
    
    func showImagePicker() {
        self.navigationController?.present(imagePicker, animated: true, completion: { [unowned self] in
            self.configureViewForNewData()
        })
    }
    
    func configureViewForNewData() {
        nameLabel.text = ""
        flowerDescription.text = ""
        pictureImageView.image = nil
        flowerImageView.image = nil
    }
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.showsCameraControls = true
    }
    
    func configurePictureImageView() {
        pictureImageView.layer.cornerRadius = pictureImageView.frame.width/2
        pictureImageView.layer.masksToBounds = true
    }
    
    /**
     * Where Machine Learning comes to play!
     **/
    func analyseData(_ image: CIImage){
        //Create a model based in our exported model
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Unable to create flower Model")
        }
        
        //Create a request, that defines whats goind to be done when the model returns the results
        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            guard let firstResult = request.results?.first as? VNClassificationObservation else {
                fatalError("Unable to get classifications from image")
            }
            self.fetchData(firstResult, completion: {  (_flower) in
                self.updateUI(_flower)
            })
        })
        
        //Creates a handler to perform the reques
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            fatalError("Unable to handle the request")
        }
    }
    
    func fetchData(_ classification: VNClassificationObservation, completion: @escaping (Flower) -> ()) {
        SVProgressHUD.show()
        
        let wikipediaURL = "https://en.wikipedia.org/w/api.php"
        let params : [String: String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "info|extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : classification.identifier,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize": "500",
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: params).validate().response { response in
            SVProgressHUD.dismiss()
            
            guard let responseData = try? response.data! else {
                return
            }
            guard let flowerJSON = try? JSON(data: responseData) else {
                return
            }
            print(flowerJSON)
            let pageId = flowerJSON["query"]["pageids"][0].stringValue
            let flowerTitle = flowerJSON["query"]["pages"][pageId]["title"].stringValue
            let extract = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
            let imageUrl = flowerJSON["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
            
            let flower = Flower(name: flowerTitle, description: extract, latinName: "LatinName", pictureUrl: imageUrl)
            completion(flower)
        }
    }
    
    func updateUI(_ flower: Flower) {
        self.nameLabel.text = flower.name
        self.flowerDescription.text = flower.description
        self.pictureImageView.image = imageHolder
        self.flowerImageView.sd_setImage(with: URL(string: flower.pictureUrl!), completed: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Unable to get image from picker")
        }
        guard let ciImage = CIImage(image: selectedImage) else {
            fatalError("Unable to get CIimage from UIImage ")
        }
        self.imageHolder = selectedImage
        self.analyseData(ciImage)
        self.dismiss(animated: true, completion: nil)
    }
    
}

