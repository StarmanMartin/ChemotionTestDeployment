# ChemotionTestDeployment
Docker container factory for test deployments


## How to use it

**This is only for testing and should not be used in production. PLEASE down the container after you are done!**

This reop hosts a dockerfile that can be used to create a docker image to dynamically host Chemotion quickly and easily. 

You can find it in the Docker hub under mstarman/chemotion-eln-test:0.0.1.

The docker compose file in this repo shows how it can be used. Other elements such as ChemSpectra or ChemConverter can also be easily added to the compose file. 

This Repo contains a .env.sample file. Please copy it as .env in the directory of your compose file. Make sure that all environment variables are correct. MAke sure you have checked the PUBLIC_URL variable.

You should add a shared folder into the same directory. This directory should contain 4 subdirectory. We recoment to clone the directory from this Repo:

- backup: Every time the container in restarted it will make a DB dump into this folder
- pullin: It overwrites files in the app (on every restart of the container). You can use it to overwrite the config files
- restore: you can put .spl files in there. The latest file in this folder will be used to populate the DB. (After restoring the DB will be migrated)
- shell_script: All .sh scripts in this folder will be executed on restart. This can be used to install (apt install ...) packages or reset environment variables as in the "set_branch.sh" script.  

To change the branch simply change the exported ELN_BRANCH in the set_branch.sh scripts!