import copy
import sys

import cntk
import time

import cntk
import cv2
import numpy as np
from PIL import Image
from flask import Flask
from multiprocessing import Process
import queue
from queue import Queue
from threading import Thread

app = Flask(__name__)


MODEL_FILENAME = '../model.onnx'
LABELS_FILENAME = '../labels.txt'


global cap
global model
global od_model
global hand_x, hand_y
global frame
global predictions

@app.route('/')
def get_raise():
    global frame
    condition = False
    listOfHighest = []
    frameCounter = 0
    while frameCounter < 3:

        ret, frame = cap.read()

        predictionThreshold = 30
        image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

        predictions = od_model.predict_image(image)
        highest = 0
        if (len(predictions) > 0):
            for a in range(len(predictions)):
                if predictions[a].get('probability') > highest:
                    highest = predictions[a].get('probability') * 100
        if (len(listOfHighest) >= 5):
            del (listOfHighest[0])
            listOfHighest.append(highest)
        else:
            listOfHighest.append(highest)
        frameCounter+=1
    averageHighestPrediction = (sum(listOfHighest)) / len(listOfHighest)

    print("Current average: ", averageHighestPrediction)

    print(predictions)
    endResult = "0"
    print(averageHighestPrediction, predictionThreshold)
    if float(averageHighestPrediction) > float(predictionThreshold):
        endResult = "1"
        print(endResult)
        return endResult
    else:
        endResult = "0"
        print(endResult)
        return endResult

@app.route('/deep')
def get_raiseFull():
    global frame
    condition = False
    listOfHighest = []
    frameCounter = 0
    while frameCounter < 3:

        ret, frame = cap.read()

        predictionThreshold = 30
        image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

        predictionsMain = od_model.predict_image(image)
        highest = 0
        if (len(predictionsMain) > 0):
            for a in range(len(predictionsMain)):
                if predictionsMain[a].get('probability') > highest:
                    highest = predictionsMain[a].get('probability') * 100
        if (len(listOfHighest) >= 5):
            del (listOfHighest[0])
            listOfHighest.append(highest)
        else:
            listOfHighest.append(highest)
        frameCounter+=1
    averageHighestPrediction = (sum(listOfHighest)) / len(listOfHighest)

    print("Current average: ", averageHighestPrediction)

    print(predictionsMain)
    endResult = "0"
    print(averageHighestPrediction, predictionThreshold)
    if float(averageHighestPrediction) > float(predictionThreshold):
        endResult = "1," + str(predictionsMain)
        print(endResult)
        return endResult
    else:
        endResult = "0," + str(predictionsMain)

        print(endResult)
        return endResult

class ObjectDetection(object):
    """Class for Custom Vision's exported object detection model
    """

    ANCHORS = np.array([[0.573, 0.677], [1.87, 2.06], [3.34, 5.47], [7.88, 3.53], [9.77, 9.17]])
    IOU_THRESHOLD = 0.45

    def __init__(self, labels, prob_threshold=0.10, max_detections=20):
        """Initialize the class

        Args:
            labels ([str]): list of labels for the exported model.
            prob_threshold (float): threshold for class probability.
            max_detections (int): the max number of output results.
        """

        assert len(labels) >= 1, "At least 1 label is required"

        self.labels = labels
        self.prob_threshold = prob_threshold
        self.max_detections = max_detections

    def _logistic(self, x):
        return np.where(x > 0, 1 / (1 + np.exp(-x)), np.exp(x) / (1 + np.exp(x)))

    def _non_maximum_suppression(self, boxes, class_probs, max_detections):
        """Remove overlapping bouding boxes
        """
        assert len(boxes) == len(class_probs)

        max_detections = min(max_detections, len(boxes))
        max_probs = np.amax(class_probs, axis=1)
        max_classes = np.argmax(class_probs, axis=1)

        areas = boxes[:, 2] * boxes[:, 3]

        selected_boxes = []
        selected_classes = []
        selected_probs = []

        while len(selected_boxes) < max_detections:
            # Select the prediction with the highest probability.
            i = np.argmax(max_probs)
            if max_probs[i  ] < self.prob_threshold:
                break

            # Save the selected prediction
            selected_boxes.append(boxes[i])
            selected_classes.append(max_classes[i])
            selected_probs.append(max_probs[i])

            box = boxes[i]
            other_indices = np.concatenate((np.arange(i), np.arange(i + 1, len(boxes))))
            other_boxes = boxes[other_indices]

            # Get overlap between the 'box' and 'other_boxes'
            x1 = np.maximum(box[0], other_boxes[:, 0])
            y1 = np.maximum(box[1], other_boxes[:, 1])
            x2 = np.minimum(box[0] + box[2], other_boxes[:, 0] + other_boxes[:, 2])
            y2 = np.minimum(box[1] + box[3], other_boxes[:, 1] + other_boxes[:, 3])
            w = np.maximum(0, x2 - x1)
            h = np.maximum(0, y2 - y1)

            # Calculate Intersection Over Union (IOU)
            overlap_area = w * h
            iou = overlap_area / (areas[i] + areas[other_indices] - overlap_area)

            # Find the overlapping predictions
            overlapping_indices = other_indices[np.where(iou > self.IOU_THRESHOLD)[0]]
            overlapping_indices = np.append(overlapping_indices, i)

            # Set the probability of overlapping predictions to zero, and udpate max_probs and max_classes.
            class_probs[overlapping_indices, max_classes[i]] = 0
            max_probs[overlapping_indices] = np.amax(class_probs[overlapping_indices], axis=1)
            max_classes[overlapping_indices] = np.argmax(class_probs[overlapping_indices], axis=1)

        assert len(selected_boxes) == len(selected_classes) and len(selected_boxes) == len(selected_probs)
        return selected_boxes, selected_classes, selected_probs

    def _extract_bb(self, prediction_output, anchors):
        assert len(prediction_output.shape) == 3
        num_anchor = anchors.shape[0]
        height, width, channels = prediction_output.shape
        assert channels % num_anchor == 0

        num_class = int(channels / num_anchor) - 5
        assert num_class == len(self.labels)

        outputs = prediction_output.reshape((height, width, num_anchor, -1))

        # Extract bouding box information
        x = (self._logistic(outputs[..., 0]) + np.arange(width)[np.newaxis, :, np.newaxis]) / width
        y = (self._logistic(outputs[..., 1]) + np.arange(height)[:, np.newaxis, np.newaxis]) / height
        w = np.exp(outputs[..., 2]) * anchors[:, 0][np.newaxis, np.newaxis, :] / width
        h = np.exp(outputs[..., 3]) * anchors[:, 1][np.newaxis, np.newaxis, :] / height

        # (x,y) in the network outputs is the center of the bounding box. Convert them to top-left.
        x = x - w / 2
        y = y - h / 2
        boxes = np.stack((x, y, w, h), axis=-1).reshape(-1, 4)

        # Get confidence for the bounding boxes.
        objectness = self._logistic(outputs[..., 4])

        # Get class probabilities for the bounding boxes.
        class_probs = outputs[..., 5:]
        class_probs = np.exp(class_probs - np.amax(class_probs, axis=3)[..., np.newaxis])
        class_probs = class_probs / np.sum(class_probs, axis=3)[..., np.newaxis] * objectness[..., np.newaxis]
        class_probs = class_probs.reshape(-1, num_class)

        assert len(boxes) == len(class_probs)
        return (boxes, class_probs)

    def predict_image(self, image):
        inputs = self.preprocess(image)
        prediction_outputs = self.predict(inputs)
        return self.postprocess(prediction_outputs)

    def preprocess(self, image):
        image = image.convert("RGB") if image.mode != "RGB" else image
        image = image.resize((416, 416))
        return image

    def predict(self, preprocessed_inputs):
        """Evaluate the model and get the output

        Need to be implemented for each platforms. i.e. TensorFlow, CoreML, etc.
        """
        raise NotImplementedError

    def postprocess(self, prediction_outputs):
        """ Extract bounding boxes from the model outputs.

        Args:
            prediction_outputs: Output from the object detection model. (H x W x C)

        Returns:
            List of Prediction objects.
        """
        boxes, class_probs = self._extract_bb(prediction_outputs, self.ANCHORS)

        # Remove bounding boxes whose confidence is lower than the threshold.
        max_probs = np.amax(class_probs, axis=1)
        index, = np.where(max_probs > self.prob_threshold)
        index = index[(-max_probs[index]).argsort()]

        # Remove overlapping bounding boxes
        selected_boxes, selected_classes, selected_probs = self._non_maximum_suppression(boxes[index],
                                                                                         class_probs[index],
                                                                                         self.max_detections)

        return [{'probability': round(float(selected_probs[i]), 8),
                 'tagId': int(selected_classes[i]),
                 'tagName': self.labels[selected_classes[i]],
                 'boundingBox': {
                     'left': round(float(selected_boxes[i][0]), 8),
                     'top': round(float(selected_boxes[i][1]), 8),
                     'width': round(float(selected_boxes[i][2]), 8),
                     'height': round(float(selected_boxes[i][3]), 8)
                 }
                 } for i in range(len(selected_boxes))]
class CNTKObjectDetection(ObjectDetection):
    """Object Detection class for CNTK
    """
    def __init__(self, model, labels):
        super(CNTKObjectDetection, self).__init__(labels)
        self.model = model
        
    def predict(self, preprocessed_image):
        inputs = np.array(preprocessed_image, dtype=np.float32)[:,:,(2,1,0)] # RGB -> BGR
        inputs = np.ascontiguousarray(np.rollaxis(inputs, 2))

        outputs = self.model.eval({self.model.arguments[0]: [inputs]})
        return np.squeeze(outputs).transpose((1,2,0))


def main():
    global cap, model, od_model, frame
    cap = cv2.VideoCapture(1)
    ret, frame = cap.read()
    model = cntk.Function.load(MODEL_FILENAME, format=cntk.ModelFormat.ONNX)

    # Load labels
    with open(LABELS_FILENAME, 'r') as f:
        labels = [l.strip() for l in f.readlines()]

    od_model = CNTKObjectDetection(model, labels)


def showImage():
    global od_model, cap, frame, predictions

    while True:
        #newframe = copy.copy(frame)

        #image = Image.fromarray(cv2.cvtColor(newframe, cv2.COLOR_BGR2RGB))
        #predictionsImage = predictions

        #highestProbabilityImage = 0
        #if len(predictionsImage) != 0:
         #    for i in range(len(predictionsImage)):
         #        if predictionsImage[i]['probability'] > predictionsImage[highestProbabilityImage]['probability']:
        #            highestProbabilityImage = i

         #    print("Height:", height, " | Width: ", width)
         #    print("Prediction left: ", predictionsImage[highestProbabilityImage]['left'] * width)
      #  print(type(predictionsImage))
        ret, myframe = cap.read()
        #height, width, channels = frame.shape
        #superframe =     cv2.circle(frame,(predictionsImage[highestProbabilityImage]['width']* width,predictionsImage[highestProbabilityImage]['top']*height),40,(255,0,0),3)

        #font = cv2.FONT_HERSHEY_SIMPLEX
      #  if len(predictionsImage) != 0:
            #myframe =  cv2.putText(superframe, ('Probability: ',predictionsImage[highestProbabilityImage]['probability']*100), (10, 500), font, 20, (255, 255, 255), 2, cv2.LINE_AA)

        #else:

        cv2.imshow("Frame",myframe)
        givenKey = cv2.waitKey(50)  # every one millisecond
        if givenKey == ord('x'):
            cap.release()
            cv2.destroyAllWindows()
            sys.exit()
def runApp():
    print("call")
    app.run(host='0.0.0.0',port=5000)

if __name__ == '__main__':
    predictions = []
    main()
    #runApp()
    appThread = Thread(target=runApp)
    appThread.start()
    imageThread = Thread(target=showImage)
    imageThread.start()



    # if len(sys.argv) <= 1:
    #    print('USAGE: {} image_filename'.format(sys.argv[0]))
    # else:
    #    main(sys.argv[1])
