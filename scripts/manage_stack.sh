#!/bin/bash

set -e

# Description: Script to create or update AWS CloudFormation Stacks
# Author: Nicolas Neuburger
# Last Updated: 06th of April 2020

# Declare Variables
STACK_COMMAND="create-stack"
WAIT_COMMAND="stack-create-complete"
IAM_CAPABILITIES=""
WAIT_CREATE_COMPLETED=false

# User Feedback in case of wrong usage

function usage()
{
    echo "manage_stack.sh STACK_NAME TEMPLATE_FILEPATH PARAMETERS_FILEPATH"
    echo ""
    echo "./manage_stack.sh"
    echo "\t-h --help"
    echo "\t--update=Updates an existing stack"
    echo "\t-h | --help shows this helper information"
    echo ""
}


while [[ $1 = -* ]]; do

    PARAM=`echo $1 | awk -F= '{print $1}'`

    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -u | --update)
            STACK_COMMAND="update-stack"
            WAIT_COMMAND="stack-update-complete"
            ;;
        -c | --iam_capabilities)
            IAM_CAPABILITIES="--capabilities CAPABILITY_NAMED_IAM"
            ;;
        -w | --wait-create-completed)
            WAIT_CREATE_COMPLETED=true
            ;;
        *)
            echo "Error unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

aws cloudformation $STACK_COMMAND --stack-name $1 --template-body file://$2 --parameters file://$3 --region eu-central-1 $IAM_CAPABILITIES

if $WAIT_CREATE_COMPLETED ; then
    aws cloudformation wait $WAIT_COMMAND --stack-name $1
fi
