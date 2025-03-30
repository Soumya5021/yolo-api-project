import torch

def attempt_load(weights, map_location=None):
    """Load YOLOv5 model from weights file"""
    model = torch.load(weights, map_location=map_location)['model'].float()
    model.eval()
    return model
