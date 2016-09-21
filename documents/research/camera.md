Camera-research
====================

- Forum thread on SCCB ~= I2C: 
  https://e2e.ti.com/support/dsp/davinci_digital_media_processors/f/99/t/6092
- Affine transform on pixels:
  http://www.codeproject.com/Articles/42211/affine-transformations-for-images
  (is probably better resources for this, but general idea, especially
  need(?) for bilinear or other interpolation)


Transformation matrix from two lines (top line):
Matrix is scale, rotation, translation, no skew.
Scale is uniform (sx = sy), depentent on the distance between the camera and
the sudoku.

```
R = [cos(r), -sin(r), 0 ,
     sin(r),  cos(r), 0 ,
     0     ,  0     , 1 ]

T = [1, 0, dx,
     0, 1, dy,
     0, 0, 1 ]

S = [s, 0, 0,
     0, s, 0,
     0, 0, 1]

A = T*R*S = [s*cos(r), -s*sin(r), tx,
             s*sin(r),  s*cos(r), ty,
             0       ,  0       , 1 ]

defining dx = s*cos(r) and dy = s*sin(r) we get

A = [dx, -dy, tx,
     dy,  dx, ty,
     0 ,   0,  1]

```

Simplified version without translation:
```
A = [s*cos(r), -s*sin(r),
     s*sin(r),  s*cos(r)]
A = [a,-b,
     b, a]
```
(this means that the top-left corner is at 0,0 in the input, at least by
definition)

We KNOW every matrix maps 0,0 to p1, because p1 is now defined as 0,0 and any
matrix maps 0,0 to 0,0.

We then need to find a matrix mapping 252,0 to x2,y2. This is also easy:
```
A*[x2,y2] = [a*x2-b*y2, b*x2+a*y2]
a*x2-b*y2 = 252
b*x2+a*y2 = 0

a =  252x2/(x2^2 + y2^2)
b = -252y2/(x2^2 + y2^2)
```

(Notice that we map FROM BNN-friendly coordinates TO coordinates in the input
image. This way we can sample SOMETHING for all the BNN-pixels (i.e. no
holes). We can also easily check if we have the entire board: if the mapping
for any of the corners (0,0), (252,0), (0,252) and (252,252) is outside the
input image bounds, we have a problem and must move the camera (or implement
the Plank&tm;))
