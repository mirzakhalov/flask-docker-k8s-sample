import os

import os
import uuid
import json
from datetime import datetime

# absolute path to the storage. This may change in relation to the container environment
# and has to be saved/noted in Deployment.yaml file under 'mountPath'
absolute_path = '../'

def someop():
	return 'some operation'

def noop():
    return ''

def create_job_id():
    return str(uuid.uuid4().hex)

def create_job(job_id):
    # create a folder with for this job request
    path = absolute_path + 'jobs/' + job_id
    if(os.path.exists(path)):
        return True

    try:  
        os.makedirs(path)
    except OSError:  
        print ("Creation of the directory %s failed" % path)
        return False
    else:  
        print ("Successfully created the directory %s " % path)
        return True

def get_status(job_id):
    path = absolute_path + 'jobs/' + job_id + '/status.txt'
    if not os.path.exists(path):
        # create a status telling something went wrong
        data = {}
        data['id'] = job_id
        data['status'] = "500"
        data['done'] = False
        data['message'] = 'Internal Server Error'
        
        # converting to true json. Won't work otherwise
        data = json.dumps(data)
        data = json.loads(data)
        return data
    else:
        lockfile = open(path)
        data = json.load(lockfile)
        return data

def update_status(job_id, status, done, message):
    path = absolute_path + 'jobs/' + job_id + '/status.txt'
    if os.path.exists(path):
        lockfile = open(path, 'r')
        data = json.load(lockfile)

        lockfile = open(path, 'w')
        data['status'] = status
        data['done'] = done
        data['message'] = message
        json.dump(data, lockfile)

def create_status(job_id, status, done, message, request):
    path = absolute_path + 'jobs/' + job_id + '/status.txt'
    if not os.path.exists(path):
        lockfile = open(path, 'w')
        data = {}
        data['id'] = job_id
        data['status'] = status
        data['done'] = done
        data['message'] = message
        data['request'] = request
        json.dump(data, lockfile)


def do(job_id):
    print('Your function goes here')
    update_status(job_id, '201', True, 'Done')
