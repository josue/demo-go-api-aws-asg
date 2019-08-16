#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c () {
    echo "** Trapped CTRL-C"
}

check_availability () {
    local URL=$1
    local total_checks=200
    local sleep_secs=1.5
    local checked=0
    local is_ready=0
    local RESPONSE=""

    # Note: (total_checks * sleep_secs => total secs) => ie: (200 * 1.5 => 300 secs, 5 mins)

    printf -- "-- Waiting for (ELB) API availability:  "

    while [ $checked -lt $total_checks ]
    do
        checked=$((checked+1))
        RESPONSE=`curl -s -m 1 -H 'Cache-Control: no-cache' "${URL}"`
        
        if [[ "${RESPONSE}" =~ "message" ]]; then
            is_ready=1
            break
        fi

        (for X in '-' '/' '|' '\' '.'; do echo -en "\b$X"; sleep 0.1; done;) &
        
        sleep $sleep_secs
    done

    local waited_seconds=$(echo "$checked * $sleep_secs" | bc)
    waited_seconds=${waited_seconds%.*}

    # exit quickly if the API is not ready after checkin X times
    if [ $is_ready -le 0 ]; then
        echo -e "\nERROR: API Not Ready -- Checked ${checked} times, every ${sleep_secs} secs | duration ${waited_seconds} secs"
        echo "--- Load Test skipped"
        exit 1
    fi

    # exit quickly if the API does not have the correct response
    if ! [[ "${RESPONSE}" =~ "message" ]]; then
        echo -e "\nERROR: API Not Ready -- Unexpected response: ${RESPONSE} ... shoule contain string 'message'| duration ${waited_seconds} secs"
        echo "--- Load Test skipped"
        exit 1
    fi

    echo -e "\nOK: (ELB) API is ready --- After ${checked} checks, duration ${waited_seconds} secs"
}

run_load_test () {
    local ACTION=$1
    local ENDPOINT=$2

    # if given, stress-test the API for 5 mins with 1000 concur / 10 threads
    # else simply test for 30 seconds.
    if [ "${ACTION}" = "stress" ]; then
        echo "--- Hard Stress Test for 5 mins ---"
        wrk -d 5m -c 1000 -t 10 ${ENDPOINT}
    else
        echo "--- Simple Load Test for 30 secs ---"
        wrk -d 30s ${ENDPOINT}
    fi
}

CMD=$1

# main

if [ ! -f "terraform.tfstate" ]; then
    echo "ERROR: Missing file: terraform.tfstate"
    echo "--- Load Test skipped"
    exit 1
fi

# extract the API endpoint from terraform state
API_ENDPOINT=`jq -r '.outputs.api_endpoint.value' terraform.tfstate`

 # exit quickly if the API endpoint not available
echo "API: ${API_ENDPOINT}"
if [ "${API_ENDPOINT}" = "null" ] || [ "${API_ENDPOINT}" = "" ]; then
    echo "ERROR: API Endpoint not available from file: terraform.tfstate"
    echo "--- Load Test skipped"
    exit 1
fi

echo
check_availability "${API_ENDPOINT}"

echo
run_load_test "${CMD}" "${API_ENDPOINT}"