Camera-research
====================

- Forum thread on SCCB ~= I2C: 
  https://e2e.ti.com/support/dsp/davinci_digital_media_processors/f/99/t/6092
- Affine transform on pixels:
  http://www.codeproject.com/Articles/42211/affine-transformations-for-images
  (is probably better resources for this, but general idea, especially
  need(?) for bilinear or other interpolation)


Transformation matrix from two lines (top line):
Matrix is position, rotation, scale, no skew.
```
rot =   [cos(r), -sin(r), 0 ,
         sin(r),  cos(r), 0 ,
         0     ,  0     , 1 ]

trans = [1, 0, dx,
         0, 1, dy,
         0, 0, 1 ]

scale = [sx, 0 , 0,
         0 , sy, 0,
         0 , 0 , 1]
```
