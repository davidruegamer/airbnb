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
              new_im = Image.new("RGB", (int(size[0]), int(size[1])))
              new_im.paste(im, (int((size[0]-im.size[0])//2), int((size[1]-im.size[1])//2)))
              new_im.save(f + '.jpg', 'JPEG')
          except IOError:
            print("cannot create thumbnail for '%s'" % item)
