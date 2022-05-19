import os
import time
import requests
import threading
import json

filename="/db/data/sensor_data.txt"
fg = 0
global b_time
global a_time

#key
# SecureKey = "NoKey"
#url
Restful_URL = "https://data.lass-net.org/Upload/MAPS-secure.php?"
#APP ID
# APP_ID = "MAPS6"

def upload_task():
    while True:
        global fg
        time.sleep(30)
        
        # the file modified time
        b_time = os.stat(filename).st_mtime

        if fg == 0:
            print("")
        elif int(b_time)!=int(a_time):
            # read data
            with open(filename, 'r') as f:
                firstline = f.readline().rstrip()
            
            msg = firstline.replace("/index.php?", "")
            print("message ready")

            restful_str = Restful_URL + msg
            try:
                r = requests.get(restful_str)
                print("send result")
                print(r)
                print("message sent!")
            except:
                print("internet err!!")

        # store the file modified time
        a_time = b_time
        fg = 1

#start upload routine
upload_task()

#start upload routine
# upload_t = threading.Thread(target = upload_task, name = "upload_t")
# upload_t.setDaemon(True)

#start routine job
# upload_t.start()

# wait subthreading done
# upload_t.join()
