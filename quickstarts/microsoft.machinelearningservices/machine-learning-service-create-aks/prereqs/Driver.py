import json
import numpy
from sklearn.externals import joblib
from azureml.core.model import Model
from azureml.contrib.services.aml_request import AMLRequest, rawhttp
from azureml.contrib.services.aml_response import AMLResponse


def init():
    global model
    model_path = Model.get_model_path('sklearn_regression_model.pkl')
    model = joblib.load(model_path)

@rawhttp
def run(request):
    if request.method == 'GET':
        respBody = str.encode(request.full_path)
        return AMLResponse(respBody, 200)
    elif request.method == 'POST':
        try:
            reqBody = request.get_data(False)
            raw_data = reqBody.decode("utf-8")
            data = json.loads(raw_data)['data']
            data = numpy.array(data)
            result = model.predict(data)
            result_string = json.dumps(result.tolist())
            return AMLResponse(result_string, 200)
        except Exception as e:
            error = str(e)
            return AMLResponse(error, 500)
    else:
        return AMLResponse("bad request", 500)