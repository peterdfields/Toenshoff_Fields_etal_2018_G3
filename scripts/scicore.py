#!/usr/bin/env python

#Script to download datasets from openBIS given
#a file with a list of datasets ids

from pybis import Openbis

#This function is fine. Just replace the password
def connectToOpenbis(url, username, password):

        o = Openbis(url, verify_certificates=False)
        o.login(username, password, save_token=True)

        return o

#Get the openbis url
url = "https://openbis-dsu.ethz.ch"
username = "peter.fields@unibas.ch"

#TOCHANGE
password = "password"

#Connection  to openbis server
try:
        o = connectToOpenbis(url, username, password)
        print("scicore connected successfully to openBIS : " + str(o.token))
except Exception as e: print(e)

#Set var input file. This is up to the scicore developer decides how to pass the file with the list of ids.
file_list_dataset_id = "file.txt"

#GFB will tranfer a file with a list of datasets id and the scicore server will download it
#with the below code
try:
        with open(file_list_dataset_id, "r") as fp:
                for line in fp:
                        print("Downloading of the dataset " + line)
                        ds = o.get_dataset(line)
                        ds.download(destination='.', wait_until_finished=True)
        fp.close()
except Exception as e: print(e)