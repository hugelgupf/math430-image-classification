#!/usr/bin/env python

import Image
import argparse
import os
import sys
import crop_face

parser = argparse.ArgumentParser(description='Convert images to approriate scale (360x260 rc)')
parser.add_argument('-o',help='Output Directory')
parser.add_argument('-i',help='Input Directory',action="store_true")
parser.add_argument('-c',help='Output the first filename as <input>.jpg then increment from there',type=int)
parser.add_argument('FilePath', help="Image to convert",type=str)

args=parser.parse_args()

if args.c:
  fn=args.c
else:
  fn=0

if args.o:
  if os.path.exists(args.o):
    if os.path.isdir(args.o+'/'):
      args.o+='/'
    elif not os.path.isdir(args.o):
      print("Output path exists, but is not a directory!")
      sys.exit(1)
  else:
    print("Output directory does not exists, Creating.")
    os.mkdir(args.o)

if args.i:
  if os.path.isdir(args.FilePath):
    files=[f for f in os.listdir(args.FilePath) if os.path.isfile(os.path.join(args.FilePath,f))]
  else:
    print("Input is not a Directory!")
    sys.exit(1)
elif os.path.isfile(args.FilePath): 
  files=args.FilePath
else:
  print("Input path does not exist!")
  sys.exit(2)

width = 260
height = 360
ext = ".jpg"
# resize an image using the PIL image library
# free from: http://www.pythonware.com/products/pil/index.htm
# open an image file (.bmp,.jpg,.png,.gif) you have in the working folder
if args.i:
  for fin in files:
    print(fin)
    imin = Image.open(args.FilePath + fin)
    crop_face.CropFace(imin, eye_left=(100,100), eye_right=(150,100), offset_pct=(0.2,0.2), dest_sz=(width,height)).save(args.o+ str(fn) + ext)
#    imout = imin.resize((width, height), Image.BILINEAR)
#    imout.save(args.o + str(fn) + ext)
    fn+=1
else:
    imin = Image.open(files)
    imout = imin.resize((width, height), Image.BILINEAR)
    imout.save(args.o + str(fn) + ext)
    fn+=1
