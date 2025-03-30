import numpy as np
import torch

def non_max_suppression(prediction, conf_thres=0.25, iou_thres=0.45):
    """Simplified NMS for YOLOv5"""
    xc = prediction[..., 4] > conf_thres
    output = [None] * len(prediction)
    for i, pred in enumerate(prediction):
        pred = pred[xc[i]]
        if not pred.shape[0]:
            continue
        output[i] = pred
    return output
