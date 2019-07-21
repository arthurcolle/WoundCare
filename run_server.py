import os
import sys
import inspect
import json
import random
import string
import numpy as np
from PIL import Image
from flask import Flask, request, redirect, url_for, flash, jsonify
from flask import send_from_directory, render_template, send_file
from flask_cors import CORS

## From Tensorflow notebook
import six.moves.urllib as urllib
import tensorflow as tf
from collections import defaultdict
from matplotlib import pyplot as plt

sys.path.append("./models/research/object_detection")
from object_detection.utils import ops as utils_ops
from utils import label_map_util
from utils import visualization_utils as vis_util

# MODEL_NAME = './models/research/object_detection/inference_graph_example'
MODEL_NAME = './models/research/object_detection/inference_graph_prod5'
PATH_TO_FROZEN_GRAPH = MODEL_NAME + '/frozen_inference_graph.pb'
PATH_TO_LABELS = './models/research/object_detection/training_4/labelmap.pbtxt'
# TEST_IMAGE_PATH = './IMG_2713.JPG'
# TEST_IMAGE_PATH = './IMG_2717.JPG'
TEST_IMAGE_PATH = './clean_image3.jpeg'
# TEST_IMAGE_PATH = '../images/test/IMG_1321.jpg'
category_index = label_map_util.create_category_index_from_labelmap(PATH_TO_LABELS, use_display_name=True)

# IMAGE_SIZE=(800,600)
IMAGE_SIZE=(600,800)

CLEAN_FILENAME = 'clean_image3.jpeg'
INFERENCE_FILENAME = 'inference_image3.jpeg'


static_file_dir = os.path.dirname(os.path.realpath(__file__))
app = Flask(__name__)
CORS(app)
root_dir = os.path.dirname(os.getcwd())

@app.route('/', methods=['GET'])
def main():
    return jsonify({'hello':'world'})
    # return render_template('index.html')

# @app.route('/get_clean_image', methods=['GET'])
# def get_clean_image():
#     print("WEB ASKING FOR CLEAN")
#     return send_from_directory(static_file_dir, CLEAN_FILENAME)

# @app.route('/run_the_inference', methods=['GET'])
# def run_the_inference():
#     # image = Image.open(TEST_IMAGE_PATH)
#     image = rescale_image(TEST_IMAGE_PATH)
#     image_np = load_image_into_numpy_array(image)
#     image_np_expanded = np.expand_dims(image_np, axis=0)
#     output_dict = run_inference_for_single_image(image_np_expanded, my_model)
#     vis_util.visualize_boxes_and_labels_on_image_array(
#       image_np,
#       output_dict['detection_boxes'],
#       output_dict['detection_classes'],
#       output_dict['detection_scores'],
#       category_index,
#       instance_masks=output_dict.get('detection_masks'),
#       use_normalized_coordinates=True,
#       line_thickness=8)
#     # plt.figure(figsize=IMAGE_SIZE)
#     # plt.imshow(image_np)
#     img = Image.fromarray(image_np)
#     img.save('detection_img2', format="JPEG", quality=100, progressive=True, optimize=True)
#     return render_template('index.html')    

@app.route('/upload_image', methods=['POST'])
def upload_image():
    print("Receiving image ....")
    thumbnail = request.files["formName"]
    thumbnail.save(CLEAN_FILENAME)
    print("Saved image down to " + CLEAN_FILENAME)

    # Running inference
    run_the_inference(CLEAN_FILENAME)
    full_inference_path = static_file_dir + '/' + INFERENCE_FILENAME
    print(full_inference_path)
    return send_file(full_inference_path, mimetype='image/jpg')

    # return send_from_directory(static_file_dir, INFERENCE_FILENAME)

    # return jsonify(success=True)

def run_the_inference(img_path):
    # image = Image.open(TEST_IMAGE_PATH)
    # print("\n\n\n DID YOU RESCALE THE IMAGE IN THE SAME WAY??? \n\n\n")
    image = rescale_image(img_path)
    image_np = load_image_into_numpy_array(image)
    image_np_expanded = np.expand_dims(image_np, axis=0)
    print("Running inference ...")
    output_dict = run_inference_for_single_image(image_np_expanded, my_model)
    print("Inference complete, drawing boxes")
    vis_util.visualize_boxes_and_labels_on_image_array(
      image_np,
      output_dict['detection_boxes'],
      output_dict['detection_classes'],
      output_dict['detection_scores'],
      category_index,
      instance_masks=output_dict.get('detection_masks'),
      use_normalized_coordinates=True,
      line_thickness=3)
    # plt.figure(figsize=IMAGE_SIZE)
    # plt.imshow(image_np)
    img = Image.fromarray(image_np)
    # rotated = img.rotate(270)
    img.save(INFERENCE_FILENAME, format="JPEG", quality=100, progressive=True, optimize=True)
    print("Saved down inference image!")    

def load_image_into_numpy_array(image):
  (im_width, im_height) = image.size
  return np.array(image.getdata()).reshape(
      (im_height, im_width, 3)).astype(np.uint8)

def rescale_image(image_path):
    print("Rescaling image to ")
    print(IMAGE_SIZE)
    original_img = Image.open(image_path)
    resized_img = original_img.resize(IMAGE_SIZE, Image.ANTIALIAS)
    resized_img.save('resized_img', format="JPEG", quality=100, progressive=True, optimize=True)
    return resized_img
    # resized_img.save('my_resized.jpg')

def run_inference_for_single_image(image, graph):
  
  print("Running inference!")

  with graph.as_default():
    with tf.Session() as sess:
      # Get handles to input and output tensors
      ops = tf.get_default_graph().get_operations()
      all_tensor_names = {output.name for op in ops for output in op.outputs}
      tensor_dict = {}
      for key in [
          'num_detections', 'detection_boxes', 'detection_scores',
          'detection_classes', 'detection_masks'
      ]:
        tensor_name = key + ':0'
        if tensor_name in all_tensor_names:
          tensor_dict[key] = tf.get_default_graph().get_tensor_by_name(
              tensor_name)
      if 'detection_masks' in tensor_dict:
        # The following processing is only for single image
        detection_boxes = tf.squeeze(tensor_dict['detection_boxes'], [0])
        detection_masks = tf.squeeze(tensor_dict['detection_masks'], [0])
        # Reframe is required to translate mask from box coordinates to image coordinates and fit the image size.
        real_num_detection = tf.cast(tensor_dict['num_detections'][0], tf.int32)
        detection_boxes = tf.slice(detection_boxes, [0, 0], [real_num_detection, -1])
        detection_masks = tf.slice(detection_masks, [0, 0, 0], [real_num_detection, -1, -1])
        detection_masks_reframed = utils_ops.reframe_box_masks_to_image_masks(
            detection_masks, detection_boxes, image.shape[1], image.shape[2])
        detection_masks_reframed = tf.cast(
            tf.greater(detection_masks_reframed, 0.5), tf.uint8)
        # Follow the convention by adding back the batch dimension
        tensor_dict['detection_masks'] = tf.expand_dims(
            detection_masks_reframed, 0)
      image_tensor = tf.get_default_graph().get_tensor_by_name('image_tensor:0')

      # Run inference
      output_dict = sess.run(tensor_dict,
                             feed_dict={image_tensor: image})

      # all outputs are float32 numpy arrays, so convert types as appropriate
      output_dict['num_detections'] = int(output_dict['num_detections'][0])
      output_dict['detection_classes'] = output_dict[
          'detection_classes'][0].astype(np.int64)
      output_dict['detection_boxes'] = output_dict['detection_boxes'][0]
      output_dict['detection_scores'] = output_dict['detection_scores'][0]
      if 'detection_masks' in output_dict:
        output_dict['detection_masks'] = output_dict['detection_masks'][0]
  return output_dict

def setup_app(app):

    global my_model
    
    my_model = tf.Graph()
    with my_model.as_default():
      od_graph_def = tf.GraphDef()
      with tf.gfile.GFile(PATH_TO_FROZEN_GRAPH, 'rb') as fid:
        serialized_graph = fid.read()
        od_graph_def.ParseFromString(serialized_graph)
        tf.import_graph_def(od_graph_def, name='')


if __name__ == "__main__":
    # rescale_image(TEST_IMAGE_PATH)
    print("setting up app and TF model ...")
    setup_app(app)
    # print("Finished app setup ...")
    run_the_inference(CLEAN_FILENAME)
    # run_the_inference(TEST_IMAGE_PATH)

    app.run(host='0.0.0.0', port=5500, debug=False)


