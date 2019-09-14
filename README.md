<img src="https://i.imgur.com/AzjUL2p.png" width="100" height="100" float="right">

# FlowerProject-CoreML
This app uses ML to detect flower types, then get the species info from Wikipedia Api and shows in the app.

## Some Cool details about this project:
- It converts a custom model made in Caffe to .mlmodel using a *coremltools*.
- It was also my first app using CoreML 😁
- Once the flower is classified, their data is fetched from Wikipedia API.

## Before running:
Please download the FlowerClassifier.mlmodel [here](https://drive.google.com/file/d/1sJE6V-rFpm0ME4vxmc2WTviFm0ZsQQmb/view?usp=sharing), and simply drag and drop the .mlmodel anywhere in the FlowerApp project. I suggest putting it inside the Model folder, solely for organization. After that, build and run.

If you want to try out converting a model to .mlmodel using *coremltools*, you can follow the instructions bellow.

## Converting from Caffe:
Download the Oxford102.caffemodel [here](https://drive.google.com/open?id=1PweirJBHzGWrNSv0b1KT6FmlbK5VVeW4) and drop it into the Flower Classifier folder. After that, run `python model.converter.py`, grab the .mlmodel generated and drop into your Xcode project. After that, build and run.

### If you have any suggestion, please open an issue!

Keep Coding,

Gabriel
