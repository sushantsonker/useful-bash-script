#!/bin/bash
kubectl config get-contexts | awk '{print $1}' > contexts.txt
awk '!/*/' contexts.txt > temp && mv temp contexts.txt
awk '!/CURRENT/' contexts.txt > temp && mv temp contexts.txt

manifest=manifest.yaml
while IFS= read -r LINE; do
    kubectl config use-context $LINE
    kubectl --cluster=$LINE apply -f $manifest
done < contexts.txt > output.txt
