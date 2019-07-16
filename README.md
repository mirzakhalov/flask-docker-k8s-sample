# Sample Flask Project with standard DevOps structure wrapped as a Docker container and deployed to K8S on IBM Cloud 

* To run the project locally: (Python 3.0+)
     * pip install -r requirements.txt
     * python app.py
     * curl localhost:5000/noop (return nothing)
     * curl -X POST localhost:5000/jobs

* To deploy the project to K8S:
     * docker built -t *|name|* .
     * docker push *|name|* *|remote_host|*
     * "Update the fields in all .yaml files with the container and remote_host names"
     * "setup K8S access to your cluster"
     * kubectl apply -f k8s/storage/pvc.yaml (takes a minute)
     * kubectl apply -f k8s/basic/deployment.yaml
     * kubectl apply -f k8s/basic/service.yml
     * kubectl describe nodes (note the 'External IP' on one of the nodes)
     * curl *|external_ip|*:*|port|*/noop (port will be chosen in service.yml e.g. 30001)


You can setup the ingress to work with your service. Then, you can access your service using the hostname provided in your ingress.yaml file. e.g `curl example.us-south.containers.appdomain.cloud/noop`


## Structure of the project

Notification Service uses *synchronous job id* schema in which a request that has been received will be assigned a job id and started off as a separate thread. Job ID will be returned to the client synchronously. Client can check the status of the job, by invoking '/jobs/*|job_id|*'. Within the system, job gets tracked using a status.txt file which gets updated every time a new phase of the execution kicks in. 

## Structure of the Cloud Deployment

pvc.yaml - Stands for Persistent Volume Claim. This uses the admin account to provision storage on IBM Cloud Storage with NFS Provisioning. This way, there is no need to manually allocate new PVs. Once the storage is provisioned, PVC also authorizes itself to access the storage, which is transitive to the Deployments that implement this PVC

deployment.yaml - Creates as many apods as specified in the file, as well as attaching PVC and setting up a mount path. Remote host of the Docker image that needs to be loaded also has to be specified in this file, along with which port will expose your server locally.

service.yml - Exposes your deployment/pods to the outside world. 5 digit port number can be specified as the access point to a specific deployment under the field NodePort. There is also a field with the name 'Port' which refers the local port that serves inside the container. i.e 5000 for Flask. 

## Invocations and Endpoints


1. Noop
- Endpoint:                               'hostname':30002/noop
- Type:                                   GET
- Return:                                 204

2. Create Jobs
- Endpoint:                               'hostname':30002/jobs
- Type:                                   POST
- Return:                                 200, JSON with status

3. Check Notification Job ID
- Endpoint:                               'hostname':30002/jobs/<job-id>
- Type:                                   GET
- Return:                                 200, JSON with status



@author Created by Jam Mirzakhalov, 2019