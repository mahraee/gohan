import numpy as np
import tensorflow as tf

loaded_model = tf.keras.models.load_model('model.h5')

class_names = ['Lentil soup', 'Fattah', 'Ful medames', 'Qatayef', 'Kanafeh', 'Koshary', 'Stuffed grape leaves', 'Molokhia', 'Om Ali', 'Rokak', 'Asabe zainab', 'Falafel']

def predict_img(img_path):
  img = tf.keras.preprocessing.image.load_img(
      img_path, target_size=(224, 224)
  )
  img_array = tf.keras.preprocessing.image.img_to_array(img)
  img_array = tf.expand_dims(img_array, 0)

  scores = loaded_model.predict(img_array)

  return class_names[np.argmax(scores)], np.max(scores)


img_path = '/content/koshary.jpg'
predict_img(img_path)