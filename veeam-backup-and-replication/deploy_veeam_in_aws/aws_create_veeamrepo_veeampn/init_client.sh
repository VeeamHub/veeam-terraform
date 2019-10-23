#!/bin/sh

function trim
{
    DATA="$1"
    t="${DATA%\"}"
    RES="${t#\"}"
    echo "$RES"
}

function log 
{
    if [[ "$VEEAMPN_TEST_LOG_FILE" = "" ]]; then
        echo "$(date +%Y-%m-%dT%H:%M:%S:%N -u) $@"
    else
        echo "$(date +%Y-%m-%dT%H:%M:%S:%N -u) $@" >> "$VEEAMPN_TEST_LOG_FILE"
    fi
}

function check_val
{
    if [[ "$1" = "" ]]; then
    (>&2 echo "$2");
    exit -1
    fi
    echo $(trim "$1")
}

function validate_res
{
    ERR=$(echo "$CALL_RES" | jq '.error.code')
    if [[ "$ERR" != null ]]; then
    log "ERROR!!!"
    log "$CALL"
    log "$CALL_RES"
    exit -1
    fi
}

function call_jsonrpc
{
if [ "$AUTH_TOKEN" = "" ]; then
    log "AUTH_TOKEN needs to be set"
    exit -1
fi

CALL="$1"
CALL_URL="$2"

CALL_RES=$(curl -sS -k -X POST -H 'Content-type: application/x-www-form-urlencoded' -H "Authorization: Bearer ${AUTH_TOKEN}" --data "$CALL" "$CALL_URL")
validate_res
}

function call_jsonrpc_datafile
{
if [ "$AUTH_TOKEN" = "" ]; then
    log "AUTH_TOKEN needs to be set"
    exit -1
fi

CALL_FILENAME="$1"
CALL_URL="$2"

CALL_RES=$(curl -sS -k -X POST -H 'Content-type: application/x-www-form-urlencoded' -H "Authorization: Bearer ${AUTH_TOKEN}" --data @"$CALL_FILENAME" "$CALL_URL")
validate_res
}

function call_authorize
{
    USERNAME="$1"
    PASSWORD="$2"
    URL="$3"

    if [ "$USERNAME" = "" ]; then
    log "Need USERNAME";
    exit -1
    fi

    if [ "$PASSWORD" = "" ]; then
    log "Need PASSWORD";
    exit -1
    fi

    if [ "$URL" = "" ]; then
    log "Need URL";
    exit -1
    fi


    CALL="{ \"jsonrpc\":\"2.0\",\"method\" : \"login\", \"params\" : {\"username\":\"$USERNAME\", \"password\":\"$PASSWORD\"},  \"id\" : 123 }"  
    CALL_RES=$(curl -sS -k -X POST -H 'Content-type: application/x-www-form-urlencoded' --data "$CALL" "$URL"/auth )

    if [[ $? != 0 ]]; then
    log "Failed to Autorize"
    exit -1
    fi
    validate_res
    RES=$(echo "$CALL_RES" | jq  '.result.token')
    AUTH_TOKEN=$(trim "$RES")
}

function ovpn_init
{
    PROT=$(check_val "$1" "Need Protocol")
    PORT=$(check_val "$2" "Need Port")
    TO_URL=$(check_val "$3" "Need URL")

    call_jsonrpc '{"jsonrpc":"2.0","method":"initServer","params":{"protocol":"'$PROT'", "externalPort":'$PORT'},"id":123}' $TO_URL
}

function ovpn_getServerConfig
{
    TO_URL=$(check_val "$1" "Need URL")

    call_jsonrpc '{"jsonrpc":"2.0","method":"getServerSettings","params":{},"id":123}' $TO_URL
}

function ovpn_find_client_id
{
    CLI_NAME=$(check_val "$1" "Need name")
    TO_URL=$(check_val "$2" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getClients", "params" : {}, "id" : 123 }'  $TO_URL
    CLI_ID=$(echo $CALL_RES | jq '.result.clients[]? |select(.name=="'$CLI_NAME'").id')
}

function ovpn_add_client
{
    CLI_TYPE=$(check_val "$1" "Need type (site|endpoint)")
    CLI_NAME=$(check_val "$2" "Need name")
    CLI_NET=$(check_val "$3" "Need net address")
    TO_URL=$(check_val "$4" "Need url")

    if [[ "$CLI_TYPE" == "endpoint" ]]; then
    log "Client is $CLI_TYPE type - so add without props"
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "addClient", "params" : {"type":"'$CLI_TYPE'", "name":"'$CLI_NAME'", "props":{}}, "id" : 123 }'  $TO_URL
    else
    log "Client is $CLI_TYPE type - so specify network address $CLI_NET"
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "addClient", "params" : {"type":"'$CLI_TYPE'", "name":"'$CLI_NAME'", "props":{"networkAddress":"'$CLI_NET'"}}, "id" : 123 }'  $TO_URL
    fi
    CLI_ID=$(echo $CALL_RES | jq '.result.id')
}

function ovpn_rename_client
{
    CLI_ID=$(check_val "$1" "Need ID")
    CLI_NAME=$(check_val "$2" "Need name")
    TO_URL=$(check_val "$3" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "editClient", "params" : {"id":'$CLI_ID', "name":"'$CLI_NAME'", "props":{}}, "id" : 123 }'  $TO_URL

    SUCCESS=$(echo $CALL_RES | jq '.result')
    if [[ "$SUCCESS" != "true" ]]; then
    log "Client was not renamed properly!"
    exit -1
    fi
}


function ovpn_delete_client
{
    CLI_ID=$(check_val "$1" "Need ID")
    TO_URL=$(check_val "$2" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "deleteClient", "params" : {"id":'$CLI_ID'}, "id" : 123 }'  $TO_URL
    SUCCESS=$(echo $CALL_RES | jq '.result')
    if [[ "$SUCCESS" != "true" ]]; then
    log "Client was not deleted properly!"
    exit -1
    fi
}


function ovpn_download_file
{
    CLI_ID=$(check_val "$1" "Need client id")
    TO_URL=$(check_val "$2" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "downloadConfig", "params" : {"id":'$CLI_ID' }, "id" : 123 }'  $URL/clients
    CLI_FILE_NAME=$(echo $CALL_RES | jq '.result.filename')
    CLI_FILE_NAME="${CLI_FILE_NAME%\"}"
    CLI_FILE_NAME="${CLI_FILE_NAME#\"}"
    CLI_FILE_DATA=$(echo $CALL_RES | jq '.result.packageFile')
    CLI_FILE_DATA="${CLI_FILE_DATA%\"}"
    CLI_FILE_DATA="${CLI_FILE_DATA#\"}"

    echo $CLI_FILE_DATA > $CLI_FILE_NAME
}

function ovpn_init_client
{
    CLI_CFG_FILE=$(check_val "$1" "Need client config file")
    TO_URL=$(check_val "$2" "Need url")

    echo -ne '{ "jsonrpc":"2.0","method" : "initClient", "params" : {"packageFile":"' > request.json
    cat "$CLI_CFG_FILE" >> request.json
    echo -ne '" }, "id" : 123 }' >> request.json
    call_jsonrpc_datafile request.json  $TO_URL
}



function ovpn_startVPN
{
    TO_URL=$(check_val "$1" "Need URL")

    call_jsonrpc '{"jsonrpc":"2.0","method":"startVPN","params":{},"id":123}' $TO_URL
    SUCCESS=$(echo $CALL_RES | jq '.result')
    if [[ "$SUCCESS" != "true" ]]; then
    log "Failed to start VPN"
    exit -1
    fi
}



function ovpn_stopVPN
{
    TO_URL=$(check_val "$1" "Need URL")

    call_jsonrpc '{"jsonrpc":"2.0","method":"stopVPN","params":{},"id":123}' $TO_URL
    SUCCESS=$(echo $CALL_RES | jq '.result')
    if [[ "$SUCCESS" != "true" ]]; then
    log "Failed to stop VPN"
    exit -1
    fi
}

function mon_client_status
{
    CLI_NAME=$(check_val "$1" "Need name")
    TO_URL=$(check_val "$2" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getConnections", "params" : { "showOnlyConnected":false}, "id" : 123 }'  $TO_URL
    CLI_STATUS=$(echo $CALL_RES | jq -r '.result.connections[]? |select(.name=="'$CLI_NAME'").status')
}


function mon_client_traffic
{
    TO_FILE=$(check_val "$1" "Need filename")
    FIRST_POS_ID=$(check_val "$2" "Need name for first position")
    TO_URL=$(check_val "$3" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getConnections", "params" : { "showOnlyConnected":false}, "id" : 123 }'  $TO_URL/monitor

    echo $CALL_RES | jq  -r '.result.connections[]?|("'$FIRST_POS_ID'\(if .name == "server" then "HUB" else .name end),'$FIRST_POS_ID'\(.traffic.in|tonumber|floor)")' >> $TO_FILE
    echo $CALL_RES | jq  -r '.result.connections[]?|("'$FIRST_POS_ID$FIRST_POS_ID'\(if .name == "server" then "HUB" else .name end),\(.traffic.out|tonumber|floor)")' >> $TO_FILE
}


function mon_client_metrics
{
    TO_URL=$(check_val "$1" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getPerfObjects", "params" : {"filterType" : "",   "filterMetric" : ""}, "id" : 123 }'  $TO_URL/monitor
    echo $CALL_RES | jq -r '.result[]?|(.metricName)' | sort | uniq
}



# connect to localhost
function LOCAL_call_authorize
{
    AUTH_USERNAME=$(check_val "$1" "Need username - 1st argument")
    AUTH_URL=$(check_val "$2" "Need URL - 1st argument")

    AUTH_RES=""
    TRY=0

    while [ ${TRY} -ne 5 ] && [ "$AUTH_RES" = "" ] ; do
    AUTH_RES=$(echo -e "getToken\t$AUTH_USERNAME" | socat UNIX-CONNECT:$AUTH_URL -)

    if [[ $? != 0 ]]; then
        log "Failed to Local Autorize"
        exit -1
    fi

    if [[ "$AUTH_RES" = "" ]]; then
        log "Failed to obtain auth token from LOCAL_AUTH - $TRY"
        sleep 1
    fi


    ((TRY=TRY+1))
    done

    if [[ ${TRY} -eq 5 ]]; then
    log "Cannot connect to LOCAL_AUTH - 5 retries"
    exit -1
    fi

    AUTH_TOKEN=$AUTH_RES
}

function mgmt_reset
{
    TO_URL=$(check_val "$1" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "resetConfig", "params" : {},  "id" : 123 }'  $TO_URL
}

function mgmt_get_version
{
    TO_URL=$(check_val "$1" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getVersion", "params" : {},  "id" : 123 }'  $TO_URL
    MGMT_VERSION=$(echo $CALL_RES | jq '.result')
}

function mgmt_get_op_mode
{
    TO_URL=$(check_val "$1" "Need url")
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getOperationalMode", "params" : {},  "id" : 123 }'  $TO_URL
    OPMODE=$(echo $CALL_RES | jq '.result')
    OPMODE="${OPMODE%\"}"
    OPMODE="${OPMODE#\"}"

    if [[ "$OPMODE" == "NONE_FIRST" ]]; then
    echo "Op Mode - FIRST!"
    OPMODE="NONE"
    fi
}

function mgmt_initCA
{
    PARAMS=$(check_val "$1" "Need params as in spec")
    TO_URL=$(check_val "$2" "Need url")


    call_jsonrpc '{"jsonrpc":"2.0","method":"initCAasync","params":'"$PARAMS"',"id":123}' "$TO_URL"

    PERCENT=1
    while [[ "$PERCENT" != "100" ]]; do
    mgmt_get_op_mode $TO_URL
    log "mode is: $OPMODE"
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "initCAstatus", "params" : {},  "id" : 123 }'  $TO_URL
    PERCENT=$(echo $CALL_RES | jq '.result.percent')
    log "$PERCENT%"
    sleep 1
    done
}

function mgmt_get_publicIP
{
    TO_URL=$(check_val "$1" "Need url")
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getServerPublicIP", "params" : {},  "id" : 123 }'  $TO_URL
}

function mgmt_get_IPsettings
{
    TO_URL=$(check_val "$1" "Need url")
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getIPsettings", "params" : {},  "id" : 123 }'  $TO_URL
}

function mgmt_archiveLogs
{
    TO_URL=$(check_val "$1" "Need url")
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "archiveLogs", "params" : {},  "id" : 123 }'  $TO_URL
}

function mgmt_get_logfile
{
    TO_URL=$(check_val "$1" "Need url")
    call_jsonrpc '{ "jsonrpc":"2.0","method" : "getArchivedLogs", "params" : {},  "id" : 123 }'  $TO_URL
}

function mgmt_startSSH
{
    TO_URL=$(check_val "$1" "Need url")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "setSSH", "params" : { "serviceStarted":true, "serviceAutostart":false },  "id" : 123 }'  $TO_URL
}

function mgmt_setPassword
{
    TO_URL=$(check_val "$1" "Need url")
    USER=$(check_val "$2" "Need username")
    PASS=$(check_val "$3" "Need password")

    call_jsonrpc '{ "jsonrpc":"2.0","method" : "setPassword", "params" : {"username":"'$USER'", "password":"'$PASS'"},  "id" : 123 }'  $TO_URL
}
function main
{
    # here is the filename of the client config file - edit if needed
    CLIENT_CONFIG_FILENAME="$1"

    VEEAMPN_TEST_LOG_FILE=/var/log/Veeam/test_log_file.log
    echo "please check extended log at $VEEAMPN_TEST_LOG_FILE"
    mkdir -p ${VEEAMPN_TEST_LOG_FILE%/*}

    LOCAL_UNIX_SOCKET="/var/run/veeampn/auth_srv"
    # port for management pf VeeamPN
    LOCAL_PORT=12345

    echo "Authenticating at local service"
    # authenticate in local authentication service - it initialize the AUTH_TOKEN variable
    LOCAL_call_authorize "localadmin" "$LOCAL_UNIX_SOCKET"

    # local URL for all management calls (works only from inside of machine)
    URL="http://localhost:$LOCAL_PORT"

    echo "Resetting the appliance"
    log "Resetting the appliance"
    mgmt_reset "$URL/mgmt"

    echo "re-Authenticating at local service"
    log "re-Authenticating at local service"
    # authenticate in local authentication service - it initialize the AUTH_TOKEN variable
    LOCAL_call_authorize "localadmin" "$LOCAL_UNIX_SOCKET"

    echo "Checking version"
    # just in case let's test that management is responding
    mgmt_get_version $URL/mgmt
    echo "-VERSION=$VERSION-" $(echo $CALL_RES | jq '.result')
    log "-VERSION=$VERSION-" $(echo $CALL_RES | jq '.result')

    # OPMODE in newly setup machine should be INIT
    echo "Checking mode"
    mgmt_get_op_mode $URL/mgmt
    echo "-CURRENT_MODE=$OPMODE-"
    log "-CURRENT_MODE=$OPMODE-"

    log "setting file: $CLIENT_CONFIG_FILENAME"
    log "$URL/site_ovpn"

    # cut off XML header
    sed -i -e '/^<?xml/d' "$CLIENT_CONFIG_FILENAME"

    echo "Setting config..."
    # init VeeamPn with the config file
    ovpn_init_client "$CLIENT_CONFIG_FILENAME" "$URL/site_ovpn"

    mgmt_get_op_mode $URL/mgmt
    echo "And now -CURRENT_MODE=$OPMODE-"
    log "-CURRENT_MODE=$OPMODE-"
    # let's start the service
    # after this call client should start connecting
    ovpn_startVPN "$URL/site_ovpn"

    # wait when the connection is stablished
    MAX_WAIT_TIME=60
    COUNT=0
    echo "Checking for client to connect to the server"
    while [[ $COUNT -lt $MAX_WAIT_TIME ]]; do
    echo "Try $COUNT"
        mon_client_status "server" $URL/monitor
        if [[ "$CLI_STATUS" == "Connected" ]]; then
            echo "-Connected!-"
            log "-Connected!-"
            break
        else
            RES="false"
        fi

        ((COUNT+=1))
        sleep 1
    done


    if [[ "$CLI_STATUS" != "Connected" ]]; then
        log "ERROR!!!"
        log "Client didn't connect after $MAX_WAIT_TIME seconds of waiting"
        echo "Client didn't connect after $MAX_WAIT_TIME seconds of waiting"
        return -1
    fi

    return 0
}


if [[ "$1" == "" ]]; then
    echo "Please supply config XML filename"
    exit -1
fi

main $1
