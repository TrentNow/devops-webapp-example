DROUTE_NAME=webapp.<IP ADDRESS>.xip.io
DJOB_NAME=webapp
STAGE_NAME=dev
USER_NAME=developer
USER_PASSWD=password
SERVER=https://<IPADDRESS>:8443

oc login -u$USER_NAME -p$USER_PASSWD --server=$SERVER --insecure-skip-tls-verify

CHECKSTAGE=`oc get project | grep $STAGE_NAME | awk '{print $1}'`
if [ -z $CHECKSTAGE ]; then
  echo "Creating project $STAGE_NAME"
  oc new-project $STAGE_NAME
fi

oc project $STAGE_NAME


CHECKBC=`oc get bc | grep $DJOB_NAME | awk '{print $1}'`
if [ -z $CHECKBC ]; then
  echo "Create a $DJOB_NAME"
  oc new-build --binary --name=$DJOB_NAME
fi


BUILD_ID=`oc start-build $DJOB_NAME --follow --from-dir=${WORKSPACE}`

CHECKDC=`oc get dc | grep $DJOB_NAME | awk '{print $1}'`
if [ -z $CHECKDC ]; then
  echo "Create Deployment Config $DJOB_NAME"
  oc new-app $DJOB_NAME

  #oc deploy $DJOB_NAME

fi

CHECKROUTES=`oc get routes | grep ${DJOB_NAME} | awk '{print $1}'`
if [ -z $CHECKROUTES ]; then
  echo "Create Route $DJOB_NAME"
  oc expose service $DJOB_NAME --hostname=$DROUTE_NAME
fi

echo "you can access your apps at http://${DROUTE_NAME}"
