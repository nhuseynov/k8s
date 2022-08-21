#!/bin/bash
cacert=/root/ca.crt
cakey=/root/ca.key

if [ -z "$1" ]
then
        echo "Please provide username and namespace"
        read -p "Username: "  user
        read  -p "Namespace: " object
else
        user=$1
        object=$2
fi

#Creating private key for user that was defined in first argument
openssl genrsa -out /root/$user.key 2048
#Creating csr for our user that was defined in first argument with object as second argument
openssl req -new -key /root/$user.key -out /root/$user.csr -subj "/CN=$user/O=$object"
#Signing csr of user
openssl x509 -req -in /root/$user.csr -CA $cacert -CAkey $cakey -CAcreateserial -out /root/$user.crt -days 365
#Creating kubeconfig file for user
kubectl --kubeconfig /root/$user.kubeconfig config set-cluster kubernetes --server https://10.2.104.140:6443 --certificate-authority $cacert
kubectl --kubeconfig $user.kubeconfig config set-credentials $user --client-certificate /root/$user.crt --client-key /root/$user.key
kubectl --kubeconfig /root/$user.kubeconfig config set-context $user-kubernetes --cluster kubernetes --namespace $object --user $user

echo "-----> DONE! $user.kubeconfig is ready! <-----"

read -p "Do you want to create role for that user? y/n " role
if [ $role == y ]
then
        echo "I will do that for you"
else
        echo "Ok, bye!"
fi

