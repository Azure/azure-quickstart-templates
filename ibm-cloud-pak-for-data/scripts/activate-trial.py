import subprocess
import os
import sys, getopt
import json
import time 


def activateTrial(argv):

   # arguments
  url=argv[1]
  username=argv[2]
  password=argv[3]
  trial_lic=argv[4]

  access_command = "curl -s -k -X GET " +url+"/v1/preauth/validateAuth -u "+username+":"+password 
  authResult=json.loads(subprocess.check_output(['bash','-c', access_command]).decode('UTF-8').split('\n')[0])
  accessToken=authResult['accessToken']
  print (accessToken)
  currentTime=int(round(time.time()))
  trialTime=currentTime + (24*60*60*60)
  with open(trial_lic) as f:
    s=f.read()
    f.close()
  s=s.replace('$CurrentTS', str(currentTime))
  s=s.replace('$ETS', str(trialTime))

  with open(trial_lic, "w") as fw:
    fw.write(s) 

  trial_command= "curl -s -i -k -X POST "+url+"/api/v1/usermgmt/v1/license/update -F  'action=TrialToPermanent' -F 'upfile=@"+trial_lic+"' -H 'Content-Type: multipart/form-data' -H 'Accept: application/json' -H 'Cookie: ibm-private-cloud-session="+accessToken+"'"
  print (subprocess.check_output(['bash','-c', trial_command]).decode('UTF-8').split('\n'))
  
  with open(trial_lic, "w") as fw:
    fw.write("") 

if __name__ == "__main__":
  activateTrial(sys.argv)
