import torch
import numpy as np
from torch import nn
from torchvision import datasets, transforms, models
from torch.optim.lr_scheduler import ReduceLROnPlateau

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(device)

print(torch.__version__)

"data transformer and loader"

transform_train = transforms.Compose([transforms.RandomHorizontalFlip(),
                                      transforms.RandomRotation(10),
                                      transforms.ToTensor(),
                                      transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225))])
transform_validation = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225))])

training_dataset = datasets.ImageFolder(root='path to your training samples', transform=transform_train)
validation_dataset = datasets.ImageFolder(root='path to your validation samples', transform=transform_validation)

training_loader = torch.utils.data.DataLoader(training_dataset, batch_size=32, shuffle=True)
validation_loader = torch.utils.data.DataLoader(validation_dataset, batch_size=32, shuffle=False)

print(len(training_dataset))
print(len(validation_dataset))

class EarlyStopping:
    """Early stops the training if validation loss doesn't improve after a given patience."""
    def __init__(self, patience=7, verbose=False, delta=1e-8, path='checkpoint.pt'):
        """
        Args:
            patience (int): How long to wait after last time validation loss improved.
                            Default: 7
            verbose (bool): If True, prints a message for each validation loss improvement.
                            Default: False
            delta (float): Minimum change in the monitored quantity to qualify as an improvement.
                            Default: 0
            path (str): Path for the checkpoint to be saved to.
                            Default: 'checkpoint.pt'
        """
        self.patience = patience
        self.verbose = verbose
        self.counter = 0
        self.best_score = None
        self.early_stop = False
        self.val_loss_min = np.Inf
        self.delta = delta
        self.path = path

    def __call__(self, val_loss, model, optimizer, scheduler):

        score = -val_loss

        if self.best_score is None:
            self.best_score = score
            self.save_checkpoint(val_loss, model, optimizer, scheduler)
        elif score < self.best_score + self.delta:
            self.counter += 1
            print(f'EarlyStopping counter: {self.counter} out of {self.patience}')
            if self.counter >= self.patience:
                self.early_stop = True
        else:
            self.best_score = score
            self.save_checkpoint(val_loss, model, optimizer, scheduler)
            self.counter = 0

    def save_checkpoint(self, val_loss, model, optimizer, scheduler):
        '''Saves model when validation loss decrease.'''
        if self.verbose:
            print(f'Validation loss decreased ({self.val_loss_min:.6f} --> {val_loss:.6f}).  Saving model ...')
        torch.save({'model_state_dict': model.state_dict(),
                    'optimizer_state_dict': optimizer.state_dict(),
                    'scheduler_state_dict': scheduler.state_dict(),
                    }, self.path)

        self.val_loss_min = val_loss

classes = ('air','idle')

"ResNet-18 model"
model = models.resnet18(pretrained=True)
model.eval() # very important, need to add this after instance the model

last_layer = nn.Linear(model.fc.in_features, len(classes))
model.fc = last_layer
model.to(device)

"optimizer"
learning_rate_ini = 1e-3
optimizer = torch.optim.SGD(filter(lambda x: x.requires_grad, model.parameters()), lr=learning_rate_ini, momentum=0.9, nesterov=True)

"loss"
criterion = nn.CrossEntropyLoss()

patience_lr = 3
learning_rate_minimum = 1e-8
scheduler = ReduceLROnPlateau(optimizer, mode='min', factor=0.1, patience=patience_lr, verbose=True, min_lr=learning_rate_minimum)

resumed_epoch = scheduler.last_epoch

"early stopping"
patience_stop = 5
early_stopping = EarlyStopping(patience=patience_stop, verbose=True, path='path for saving the checkpoint')

"main entrance"
epochs_max = 1000 # maximum epochs, will not achieve this due to learning rate dropping and early stopping
running_loss_history = []
running_corrects_history = []
val_running_loss_history = []
val_running_corrects_history = []

for e in range(resumed_epoch,epochs_max):

    running_loss = 0.0
    running_corrects = 0.0
    val_running_loss = 0.0
    val_running_corrects = 0.0
    index = 0

    model.train() # for training
    for inputs, labels in training_loader:
        inputs, labels = inputs.to(device), labels.to(device)

        outputs = model(inputs)
        loss = criterion(outputs, labels)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        _, preds = torch.max(outputs, 1)
        running_loss += loss.item() * inputs.size(0)
        running_corrects += torch.sum(preds == labels.data)

    else:
        with torch.no_grad():

            model.eval() # for testing
            for val_inputs, val_labels in validation_loader:
                val_inputs, val_labels = val_inputs.to(device), val_labels.to(device)

                val_outputs = model(val_inputs)
                val_loss = criterion(val_outputs, val_labels)

                _, val_preds = torch.max(val_outputs, 1)
                val_running_loss += val_loss.item() * val_inputs.size(0)
                val_running_corrects += torch.sum(val_preds == val_labels.data)

        epoch_loss = running_loss / len(training_dataset)
        epoch_acc = running_corrects.float() / len(training_dataset)
        running_loss_history.append(epoch_loss)
        running_corrects_history.append(epoch_acc)

        val_epoch_loss = val_running_loss / len(validation_dataset)
        val_epoch_acc = val_running_corrects.float() / len(validation_dataset)
        val_running_loss_history.append(val_epoch_loss)
        val_running_corrects_history.append(val_epoch_acc)

        print('epoch :', (e + 1))
        print('training loss: {:.4f}, acc {:.4f} '.format(epoch_loss, epoch_acc.item()))

        if learning_rate_ini >= 10 * learning_rate_minimum:
            scheduler.step(val_epoch_loss) # reduce learning rate by tracking val_epoch_loss
        else:
            early_stopping(val_epoch_loss, model, optimizer, scheduler) # early stop by tracking val_epoch_loss
            if early_stopping.early_stop:
                break

        print('validation loss: {:.4f}, validation acc {:.4f} '.format(val_epoch_loss, val_epoch_acc.item()))
        print('-'*50)

        learning_rate_ini = scheduler._last_lr[0]