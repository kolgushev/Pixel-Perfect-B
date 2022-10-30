import cv2
import numpy as np

res = 512
np_img = np.random.rand(res, res, 4)

cv2.imwrite('../tex/noise/WHITE_RGBA.png', 1024 * np_img)