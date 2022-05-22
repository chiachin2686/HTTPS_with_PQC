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

function file_checked(){
    local file_path="/opt/httpd/logs/ssl_request_log"
    local check_time=30
    counter=0  # set a counter
    while [[ true ]]; do
        file_old_stat="`stat ${file_path}|grep Modify`"
        sleep ${check_time}
        file_new_stat="`stat ${file_path}|grep Modify`"
        if [ -f ${file_path} ]; then  # file exists
            if [[ `echo ${file_old_stat}` == `echo ${file_new_stat}` ]]; then
                echo "### File doesn't change ###"
            else
                grep GET ${file_path} | tail -1 | awk '{print $7}' > /db/data/sensor_data.txt  # get the last data
                if [[ "$counter" -gt 1000 ]]; then
                    sed -i '1,1000d' ${file_path}
                    counter=0
                else
                    counter=$((counter+1))
                fi
                echo "### File changes ###"
            fi
            echo "File exists."
        else
            echo "File does not exists."
        fi
    done
}

touch /db/data/sensor_data.txt

file_checked

## use '&' to execute script in background, e.g., `sh check_file.sh &`