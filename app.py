from flask import Flask,render_template, request
import base64
import io
from PIL import Image
import random
import numpy as np
import tensorflow as tf

loaded_model = tf.keras.models.load_model('model.h5')
class_names = ['8', '12', '11', '7', '6', '2', '4', '5', '1', '9', '10', '3']

def predict_img(img_path):
  img = tf.keras.preprocessing.image.load_img(
      img_path, target_size=(224, 224)
  )
  img_array = tf.keras.preprocessing.image.img_to_array(img)
  img_array = tf.expand_dims(img_array, 0) # Create a batch

  scores = loaded_model.predict(img_array)
  # predictions = np.argmax(scores, axis=-1)
  return class_names[np.argmax(scores)]



app= Flask(__name__)
@app.route('/', methods=['get'])
def hello():
	return "hello"

@app.route('/', methods=['POST'])
def predict():

	data = request.get_json(force=True)
	image_data= data['image']
	imgdata = base64.b64decode(image_data)
        
	imagepath="./images/img.jpg"
	image = Image.open(io.BytesIO(imgdata))
	
	image.save(imagepath)
	randOut=str(random.randint(1, 12))
	print(randOut)
	return predict_img(imagepath)


if __name__ == "__main__":
	app.run(host="0.0.0.0:3000",debug=True)