#!/bin/bash
# @author Upendra Chitnis
# modified by Jam Mirzakhalov on July 2, 2019
#

cluster_namespace=$1
cr_namespace=$2
image_name="notification-server"
echo "Cluster Namespace: $cluster_namespace"
echo "Container Registry Namespace: $cr_namespace"

############################################################################
# Download and install a few CLI tools and the Kubernetes Service plug-in. #
# Documentation on details can be found here:                              #
#    https://github.com/IBM-Cloud/ibm-cloud-developer-tools                #
############################################################################
echo "Install IBM Cloud CLI"
curl -sL https://ibm.biz/idt-installer | bash

############################################################################
# Log into the IBM Cloud environment using apikey                          #
############################################################################
echo "Login to IBM Cloud using apikey"
ibmcloud login -a https://api.ng.bluemix.net --apikey $FSS_DEMO_API_KEY
if [ $? -ne 0 ]; then
  echo "Failed to authenticate to IBM Cloud"
  exit 1
fi

############################################################################
# Ask Docker to tag the image as latest and with the custom tag            #
############################################################################
echo "Tagging the image as demo:$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER-$TRAVIS_BRANCH and demo:latest"
docker tag $image_name:$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER-$TRAVIS_BRANCH us.icr.io/$cr_namespace/$image_name:$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER-$TRAVIS_BRANCH
docker tag $image_name:latest us.icr.io/$cr_namespace/$image_name:latest

############################################################################
# Log into the IBM Cloud container registry                                          #
############################################################################
echo "Logging into IBM Cloud container registry"
ibmcloud cr login
if [ $? -ne 0 ]; then
  echo "Failed to authenticate to IBM Cloud container registry"
  exit 1
fi

############################################################################
# If the image exists in the container registry then delete it             #
# then recreate it                                                         #
############################################################################
echo "looking to see if the image exists"
echo "using command: ibmcloud cr images | grep us.icr.io/$cr_namespace/$image_name:$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER-$TRAVIS_BRANCH"

lookup_image=$( ibmcloud cr images | grep "us.icr.io/$cr_namespace/$image_name:$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER-$TRAVIS_BRANCH" )

echo "Now looking to see if the image exists"
echo "using command: ibmcloud cr images | grep us.icr.io/$cr_namespace/$image_name:latest"

lookup_image=$( ibmcloud cr images | grep "us.icr.io/$cr_namespace/$image_name:latest" )

############################################################################
# Push the image                                                           #
############################################################################
echo "Pushing image to registry"
#docker push us.icr.io/$cr_namespace/$image-name:$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER-$TRAVIS_BRANCH
docker push us.icr.io/$cr_namespace/$image_name:latest

#ddelete and apply deployment again
eval $(ibmcloud ks cluster-config --export fssdemo)
echo $KUBECONFIG
kubectl get nodes
kubectl delete deployment flask-docker-k8s
kubectl apply -f k8s/basic/deployment.yaml 
############################################################################
# end script                                                               #
############################################################################
