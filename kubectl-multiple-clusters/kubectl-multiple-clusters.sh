#!/bin/bash
kubectl config get-contexts | awk '{print $1}' > contexts.txt
awk '!/*/' contexts.txt > temp && mv temp contexts.txt
awk '!/CURRENT/' contexts.txt > temp && mv temp contexts.txt

manifest=manifest.yaml

cmd1="kubectl --cluster=$LINE delete -f $manifest"
cmd2="kubectl get cm -n tigera-operator"

while IFS= read -r LINE; do
    kubectl config use-context $LINE
    if $cmd1 | grep -q 'fluentd-filters'; then
       echo "success " $LINE
    fi
done < contexts.txt > output.txt
