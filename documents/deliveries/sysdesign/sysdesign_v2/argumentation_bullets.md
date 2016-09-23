Argumentation
=================

The planned operation of *sudo-ku*:
- Point camera at an image of a solved sudoku-board
  - All but the board itself should be black, the board itself white
  - The camera must be pointed roughly orthogonally to the board; we do not
    do any perspective transformations.
  - The camera can be rotated along the camera-pointing axis by 45 degree either
	way.
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

Camera (and SD-card) connected to the FPGA
-------------------------------------------------

- We need 9x9 times 28x28 pixels of relevant image data. Results in 9x9x28x28x2
  = 127008 pixels. 
- Smallest standard accomodating this is HVGA(480x320=153600 pixels). But is
  uncommonly sopported. Hence we use VGA(640x480=307200 pixels).
- We use 4 bit grayscale to store the images. Equals 307200x4=1228800 bits.
- Image from the the camera is in a different format than our 4-bit grayscale.
  This needs conversion on the fly, either on FPGA or MCU.  

Image transformation on FPGA
-------------------------------

- The process of doing an affine transformation on the camera input data is
  a simple, arithmetical operation, easy to implement elegantly on an FPGA,
  given six matrix elements.
- The resulting, transformed image/images are only needed on the FPGA

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

- This is a no-brainer
- Output, which includes communicating with a display, is a lot more difficult
  implementing in hardware, with no real benefit.
- The MCU is used to control the operation flow of *sudo-ku*.

Sudoku-checking on MCU
-----------------------

- Super easy to do on MCU.
- Have already made a first draft of about 50 lines of code checking a sudoku.
- Lots of eye-candy can be implemented when everything works
- Only ~700 ways to solve a sudoku. The entire board can be transferred from the
  FPGA to the MCU in 10 bits. Data transferred is negligible.

Having an SD-card
---------------------

- In case the camera processing does not work, we will still have a way to
  demo the working BNN by loading pre-formatted, square image data, skipping
  the transformation steps.
