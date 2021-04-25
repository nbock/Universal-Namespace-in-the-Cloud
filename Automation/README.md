# Universal Namespace in the Cloud - Automation
## 1. Purpose
The purpose of this directory is to provide the necessary scripts for running this projects automaton suite. The intended use case is for these scripts to be used in the same directory as the contents of the Dockerize directory and the OpenShiftDeploy directory.

These steps are not currently generalized, but can be easily done by changing the command line inputs within deploy_server.sh and the params.yaml file. The bulk of the implementation is done by the parse_yaml function defined in the bash script, so that should not be changed (nor should the format of params.yaml, but feel free to add or delete parameters as necessary).
