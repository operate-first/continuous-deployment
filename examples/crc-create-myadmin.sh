oc create user myadmin
oc create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=myadmin

export HTPASSWD_FILE=/tmp/htpasswd
htpasswd -c -B -b $HTPASSWD_FILE developer developer
htpasswd -b $HTPASSWD_FILE myadmin foobar68
oc create secret generic htpass-secret --from-file=$HTPASSWD_FILE -n openshift-config --dry-run=client -o yaml > /tmp/htpass-secret.yaml
oc replace -f /tmp/htpass-secret.yaml
