#!/bin/bash


###############################################
# Purpose: Compare images in use and the vulnerable images 
# to find out what needs to be patched / deleted
#####
# Input: 
# 2-kubectl-notebook: List of all notebook images used in cluster
# 4C-impacted-artifacts: List of all impacted artifacts
#####
# Actions: Using 2-kubectl-notebook's 'ImagePath', compare with 4-impacted-artifacts
# to find any hits. If there is a hit write to 5-user-items.txt
#####
# TODO: Confirm any wants for 'admin'. Right now only concerned w/ user notebooks.
# haven't done extensive testing on things we want for admin
###############################################


#####################################################################################################################
# USER/ADMIN SHARED FORMATTING 
# Avoid any escaping problems by going from `/` --> `;`
#sed -i 's/\//;/g' 4C-formatted-impacted-artifacts.txt  #now done in previous step
#sed -i 's/\//;/g' 2-notebook-images.txt # actually only used admin side, not used w/ users
#####################################################################################################################


#####################################################################################################################
# VULNERABILITIES FOR USER (sha to revert to jup cpu - dee04931)
# Returns a 5-user-items.txt containing impacted images.
#####################################################################################################################

# Avoid escaping problems and match up to impacted artifacts
sed 's/\//;/g' 2-kubectl-notebook.txt |
while read -r line
do
  # extract the image from the file, trim the quotes, and replace the `:` with a `;`` to compare with vulnerabilities
  imageCheck=$(echo $line | jq -c '.ImagePath' | tr -d '"' | sed 's/:/;/g')
  # Look for the image in the imapacted artifacts and if found print the line to the list. 
  if grep -Fxq "$imageCheck" 4C-formatted-impacted-artifacts.txt 
  then
     echo $line >> 5-impacted-notebooks.txt
  fi
done

##################################
## RIGHT NOW (for demo at least, this is all I want) ##
#This 5-user-items.txt has the information. (well it could use the label for version as well)
##################################


######################
### 19/06/2021
### I think the below items are out of scope.
### Any administrative images we use are checked.
### Only concern with notebook servers themselves.
######################


#####################################################################################################################
# VULNERABILITIES FOR ADMIN
# Need to decide if these will automatically update
#####################################################################################################################

# Step X get a list of affected pods in the cluster. 
# Having said that I wouldn't want to be an admin recieving a ton of the same info about some istio / vault vulnerability (these are in each notebook server)

#This could be UNIQ'd instead. 

# probably too much information. 
# kubectl get pods --namespace jose-matsuda -o json | jq -c '.items[] | {Namespace:(.metadata.namespace), Image:(.spec.containers[].image), Name:(.spec.containers[].name)}' > 5-kubectl-pods.txt

#instead do 
#kubectl get pods --namespace jose-matsuda -o json | jq -c '.items[] | {image:(.spec.containers[].image)} | sort | uniq' > 5-kubectl-pods.txt

# Sed the slashes to semicolons (may want to change back to slashes after comparison)
#sed -i 's/\//;/g' 5-kubectl-pods.txt

#Now do a comparison w/ 4C-formatted-impacted-artifacts.txt
# We want to keep in 5-kubectl-pods.txt what is in 4C. So remove anything not in 4C

#cat 5-kubectl-pods.txt | 
#while read -r line
#do
  # extract the image from the file, trim the quotes, and replace the : with a ;
#  imageCheck=$(echo $line | jq -c '.Image' | tr -d '"' | sed 's/:/;/g')
  # Look for the image in the imapacted artifacts and if found print the line to the list. 
#  if grep -Fxq "$imageCheck" 4C-formatted-impacted-artifacts.txt 
#  then
#     echo $line >> 5-admin-items.txt
#  fi
#done 

#cat 5-user-items-image-list.txt | sort | uniq |
#while read -r line
#do
   #Not-applicable as the notebook image (ex: jupyterlab-cpu) may be used in many notebooks across the cluster
#   echo "{"\""Namespace"\"":"\""not-applicable"\"","\""Image"\"":"\""$line"\"","\""Name"\"":"\""not-applicable"\""}" >> 5-admin-items.txt
#done
