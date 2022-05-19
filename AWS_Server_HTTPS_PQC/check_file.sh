#!/bin/bash

function file_changed(){
    local file_path="/opt/httpd/logs/ssl_request_log"
    local check_time=30
    while [[ true ]]; do
        file_old_stat="`stat ${file_path}|grep Modify`"
        sleep ${check_time}
        file_new_stat="`stat ${file_path}|grep Modify`"
        if [[ `echo ${file_old_stat}` == `echo ${file_new_stat}` ]]; then
            echo "### In ${check_time}s, ${file_path} doesn't change ###"
        else
            echo "### Wait ${check_time}s ###"
        fi
    done
}

function file_existed(){
    local file_path="/opt/httpd/logs/ssl_request_log"
    local check_time=60
    while [[ true ]]; do
        if [ -f ${file_path} ]; then  # file exists
            echo "${file_path} exists."
            grep GET ${file_path} | tail -1 | awk '{print $7}' > /db/data/sensor_data.txt  # get the last data
        else
            echo "${file_path} does not exists."
        fi
        sleep ${check_time}
    done
}

touch /db/data/sensor_data.txt

file_existed

## use '&' to execute script in background, e.g., `sh check_file.sh &`