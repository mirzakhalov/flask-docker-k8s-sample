from flask import Flask, make_response
from app.service import services as ss
from flask import request
import threading
from flask import jsonify

app = Flask(__name__)

@app.route('/noop',methods = ['GET'])
def noop():
    return make_response(ss.noop(), 204)

@app.route('/jobs', methods = ['POST'])
def notify():

    # in case request comes with json body
    body = request.get_json()

    job_id = ss.create_job_id()
    # create a folder for this job id. It returns true if the creation was successful
    if ss.create_job(job_id):
        ss.create_status(job_id, "202", False, 'Accepted', body)
        
        # start up a thread for this action and return the jobid to the requester
        action = threading.Thread(target=ss.do, args=(None, job_id))
        action.start()
    
    return jsonify(ss.get_status(job_id))

@app.route('/jobs/<job_id>', methods = ['GET'])
def check_status(job_id):
    return jsonify(ss.get_status(job_id))

app_port = 5000
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=app_port)
