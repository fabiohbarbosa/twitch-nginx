#!/bin/bash
set -e # ensure that this script will return a non-0 status code if any of rhe commands fail
set -o pipefail # ensure that this script will return a non-0 status code if any of rhe commands fail

VERSION=$1

cat << EOF > service.yaml

---
apiVersion: v1
kind: Service
metadata:
  name: frontend-nginx
spec:
  selector:
    app: frontend-nginx
  type: NodePort
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: 30002

---
apiVersion: extensions/v1beta1
kind: Deployment

metadata:
  name: frontend-nginx
  labels:
    imageTag: 'v.$VERSION'
spec:
  revisionHistoryLimit: 15
  replicas: $REPLICAS
  strategy:
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: frontend-nginx
    spec:
      containers:

      - name: frontend-nginx-nginx
        image: gcr.io/$GCP_PROJECT/frontend/splitter-nginx:v.$VERSION
        env:
          - name: ENVIRONMENT
            value: $ENVIRONMENT
        ports:
          - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /healthcheck
            port: 8080
          initialDelaySeconds: 15
          timeoutSeconds: 1
          periodSeconds: 5
          failureThreshold: 1
        livenessProbe:
          httpGet:
            path: /healthcheck
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 15
          timeoutSeconds: 5
          failureThreshold: 4
        resources:
          limits:
            memory: 200Mi
          requests:
            memory: 200Mi

EOF
cat service.yaml
kubectl apply -f service.yaml