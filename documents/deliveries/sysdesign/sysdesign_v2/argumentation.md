Argumentation
=================

The planned operation of *sudo-ku*:
- Point camera at an image of a solved sudoku-board
  - All but the board itself should be black, the board itself white (solved
    by providing standard-issue boards for use with *sudo-ku*)
  - The camera must be pointed roughly orthogonally to the board; we do not
    do any perspective transformations.
  - The camera can be rotated along the camera-pointing axis, but only by
    less than 45 degrees either way. Thus we can easily find out which part
    of the board is "up" (we cannot end up with upside-down numbers into the
    BNN).
    - This requirement might go away if we find a simple way to figure out the
      orientation without it
- Push button
- Camera image is stored in FPGA BRAM
- MCU-program figures out the transform required to make a 28*9 by 28*9 image
  from the input image
- FPGA performs transform, cutting it into pieces, trimming edges of the
  squares to avoid sending outlines into the BNN etc.
- BNN (on FPGA) detects digits
- Digits sent to MCU, where the sudoku is checked and result (and potentially
  other relevant info, incorrect rows etc.) is output to the user.

See figures for data-lifetime and top-level schematic.

Following is an argumentation for the choices we made about this design:

Camera (and SD-card) connected to the FPGA
-------------------------------------------------

- We want to be able to use an image where about half the pixels are relevant
  data. We need 9*9 times 28x28 pixels of relevant image data, which makes the
  required image size 9*9*28*28*2 pixels, aka 127008. The smallest standard
  resolution accomodating this is HVGA, 480*320=153600 pixels. If we use 4 bit
  grayscale to store the images this works out to 153600*4=614400 bits or
  ~77kB of memory required. However the HVGA resolution seems to be uncommonly
  supported by camera hardware, and we might only have access to a VGA-
  resolution (640*480) image, requiring twice the storage, ~154kB, for 4-bit
  grayscale. We do have more memory available on the FPGA (BRAM) than on the
  EFM32 (which isn't even able to store the image if it is VGA sized, and will
  have very constrained space if it needs to store even an HVGA-sized image).

- At least the BNN-computation needs access to the image data containing the
  actual sudoku board. The plan currently is to also do the transform on the
  input image, turning it into number-squares for the BNN, on the FPGA (but
  using the MCU to find the board in the image and figuring out the relevant
  transform parameters). Thus, in the best case, if we have an algorithm on
  the MCU which only needs a small part of the image data to figure out the
  orientation and scale, only the FPGA will need to access all of the input
  image data, and will serve as a sort of memory controller to give the MCU
  access to the parts it needs in order to compute the transform parameters.
  In the worst case, both the FPGA and the MCU will need the entire image,
  but then we can still use the FPGA as an (overqualified) memory controller.

- The image will most likely be supplied from the camera in a different
  format than our 4-bit grayscale format, thus needing conversion on the fly.
  This is an operation that is equally as simple to implement on the FPGA as
  on the MCU.
  
- We also discussed the difficulty of talking to the camera on the FPGA as
  opposed to on the MCU, having found some cameras that supplied only raw
  RGB data in smaller resolutions and delivering the larger resolutions JPEG-
  encoded. We imagine implementing JPEG-decoding on an FPGA is a much less
  trivial task than doing it on an MCU. However, we have since found several
  cameras supplying raw RGB-data up to VGA-size, so this will most likely
  not be a problem.

Image transformation on FPGA
-------------------------------

- The resulting, transformed image/images are only needed on the FPGA
- The process of doing an affine transformation on the camera input data is
  a simple, arithmetical operation, easy to implement elegantly on an FPGA,
  given six matrix elements.

Matrix computation on MCU
----------------------------

- An algorithm for figuring out where the board is located in the image is
  typically a task which is much more elegant (and less error-prone)
  implemented in software than in hardware. It will also be possible to
  compute with only a subset of the input pixels, thus not needing all of
  the pixels to be transferred even though we do the computation on the MCU
  and the image is stored on the FPGA.

User I/O on MCU
------------------

- Output, which includes communicating with a display, is a lot more difficult
  implementing in hardware, with no real benefit.
- The MCU is used to control the operation flow of *sudo-ku*, meaning input
  (buttons) almost always need to be input into the MCU anyway. In addition
  the amount of data represented by button input is negligible in comparison
  with i.e. the camera input data or the display output data.

Sudoku-checking on MCU
-----------------------

- Have already made a first draft of about 50 lines of code checking a sudoku.
  This is super-easy on the MCU, and the algorithm can produce a lot of by-
  products which may be of interest to the user and displayed (for instance
  which row/column/square contains incorrect numbers). There are only ~700
  ways to solve a sudoku, so the entire board can be transferred from the FPGA
  to the MCU in 10 bits. This amount of data transfer is negligible.
- Checking sudoku on the FPGA is probably only a bit more difficult, but poses
  no real advantage

Having an SD-card
---------------------

- In case the camera processing does not work, we will still have a way to
  demo the working BNN by loading pre-formatted, square image data, skipping
  the transformation steps.
