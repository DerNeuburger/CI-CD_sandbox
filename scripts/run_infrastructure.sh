#!/bin/bash

ID="example"
update=""
iac_source_path="../infrastructure-as-code"

declare -a modules=()

function usage()
{
    echo "run_infastructure.sh [Flags]"
    echo ""
    echo "./manage_stack.sh"
    echo "\t-h --help=Provision of help information"
    echo "\t--update=Updates existing stack(s)"
    echo ""
}

while [[ $1 = -* ]]; do

    PARAM=`echo $1 | awk -F= '{print $1}'`

    case $PARAM in
        --module | -m)
            modules+="$2"
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        -u | --update)
            update="-u"
            ;;
        *)
            echo "Unknown argument passed to this script."
            usage
            exit 1
            ;;
    esac
    shift
done

if ! (( ${#modules[@]} )); then
    modules=( "network" "permissions" "webservers" "ansible_master" "bastion_hosts" )
fi

for i in "${modules[@]}"
do
    echo "./manage_stack.sh -c -w "$ID-$i" ${update} "${iac_source_path}/cfn_$i.yml "${iac_source_path}/parameters_$i.json"
    ./manage_stack.sh -c -w "$ID-$i" ${update} "${iac_source_path}/cfn_$i.yml" "${iac_source_path}/parameters_$i.json"
done
