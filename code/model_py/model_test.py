import torch
import numpy as np
from torch import nn
from torchvision import datasets, transforms, models
import scipy.io

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)

transform_testing = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225))])

testing_dataset = datasets.ImageFolder(root='path to your test samples', transform=transform_testing)

testing_loader = torch.utils.data.DataLoader(testing_dataset, batch_size=32, shuffle=False)

print(len(testing_dataset))

classes = ('air','idle')

model = models.resnet18(pretrained=True)
last_layer = nn.Linear(model.fc.in_features, len(classes))
model.fc = last_layer

checkpoint = torch.load('path to your pre-saved checkpoint')

model.load_state_dict(checkpoint['model_state_dict'])

model.to(device)
model.eval()

val_prob_all = np.empty((0,2), int)

for val_inputs, val_labels in testing_loader:

    val_inputs = val_inputs.to(device)

    val_outputs = model(val_inputs)
    val_prob = torch.nn.functional.softmax(val_outputs, dim=1)
    val_prob = val_prob.detach().cpu().numpy()

    val_prob_all = np.append(val_prob_all, val_prob, axis=0)

scipy.io.savemat('prob.mat', {'prob': val_prob_all}) # save to .mat file for futher processing
