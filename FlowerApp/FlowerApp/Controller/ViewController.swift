//
//  ViewController.swift
//  FlowerApp
//
//  Created by Gabriel on 09/09/19.
//  Copyright © 2019 gabrielrodrigues. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var latinNameLabel: UILabel!
    @IBOutlet weak var flowerDescription: UITextView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePicker()
        configurePictureImageView()
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func newPressed(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.showsCameraControls = true
    }
    
    func configurePictureImageView() {
        pictureImageView.layer.cornerRadius = pictureImageView.frame.height / 2
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
            self.fetchData(firstResult, completion: {  (_image, _flower) in
                self.updateUI(_flower, with: _image)
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
    
    func fetchData(_ classification: VNClassificationObservation, completion: (CIImage, Flower) -> ()) {
        
    }
    
    func updateUI(_ flower: Flower, with image: CIImage) {
        self.nameLabel.text = flower.name
        self.pictureImageView.image = UIImage(ciImage: image)
        //        self.flo
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
        self.analyseData(ciImage)
    }
    
}

