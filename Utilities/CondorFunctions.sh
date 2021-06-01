#!/bin/bash

CondorEcho(){
echo -e "JOB $job $submit"
echo -e "VARS $job executable = \"$executable\""
echo -e "VARS $job numCPUs = \"$numCPUs\""
echo -e "VARS $job RAM = \"$RAM\""
# echo -e "VARS $job disk = \"$disk\"\n"

echo -e "VARS $job initialDir = \"$initialDir\""
echo -e "VARS $job logFile = \"${job}.log\""
echo -e "VARS $job errFile = \"${job}.err\""
echo -e "VARS $job outFile = \"${job}.out\""

echo -e "VARS $job args = \"$args\"\n"
}
export -f CondorEcho
export submit=$(pwd)/CondorLocal.submit

NonLocalCondorEcho(){
echo -e "JOB $job $nonLocalSubmit"
echo -e "VARS $job executable = \"$executable\""
echo -e "VARS $job numCPUs = \"$numCPUs\""
echo -e "VARS $job RAM = \"$RAM\""
echo -e "VARS $job disk = \"$disk\""

echo -e "VARS $job initialDir = \"$initialDir\""
echo -e "VARS $job logFile = \"${job}.log\""
echo -e "VARS $job errFile = \"${job}.err\""
echo -e "VARS $job outFile = \"${job}.out\""

echo -e "VARS $job args = \"$args\""

echo -e "VARS $job transferInputFiles = \"$transferInputFiles\""
echo -e "VARS $job transferOutputFiles = \"$transferOutputFiles\"\n"
}
export -f NonLocalCondorEcho
export nonLocalSubmit=$(pwd)/CondorNonLocal.submit
