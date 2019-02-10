import turicreate as turi
import os



def getImageFromPath(path):
    return os.path.basename(os.path.dirname(os.path.normpath(path)))

myPath = 'dataset'
data = turi.image_analysis.load_images(myPath, with_path = True)

data["people"] = data["path"].apply(lambda path: getImageFromPath(path))

print(data.groupby("people",[turi.aggregate.COUNT]))

data.save("people.sframe")

#EXPLORE ile modelin onizlemesini yapariz
#data.explore()

train_data, test_data = data.random_split(0.8)

model = turi.image_classifier.create(train_data, target='people', model='resnet-50', verbose=True)

predicitions = model.predict(test_data)

metrics = model.evaluate(test_data)

print(metrics["accuracy"])

print("Saving model")
model.save("people.model")
print("Saving core ml model")
model.export_coreml("people.mlmodel")
print("Done")
