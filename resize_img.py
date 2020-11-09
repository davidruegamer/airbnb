from PIL import Image
import os, sys

def resize_img(path, size):
  dirs = os.listdir( path )
  for item in dirs:
      if os.path.isfile(path+item):
          try:
              im = Image.open(path+item)
              f, e = os.path.splitext(path+item)
              im.thumbnail(size, Image.ANTIALIAS)
              im.save(f + '.jpg', 'JPEG')
          except IOError:
            print("cannot create thumbnail for '%s'" % item)
