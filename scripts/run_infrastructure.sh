#!/bin/bash


#Declare Variables
declare -a modules=()
IAM_CAPABILITIES=""
WAIT_CREATE_COMPLETED=false
EXTRA_PARAM=""
IAM_CAPABILITIES="--capabilities CAPABILITY_NAMED_IAM"
update=""
iac_source_path="../infrastructure-as-code"
extra_parameters=""
parameters_replaced=false

declare -a modules=()

function usage() {
	echo "run_infastructure.sh [Flags]"
	echo ""
	echo "./manage_stack.sh"
	echo "\t-h --help=Provision of help information"
	echo "\t--update=Updates existing stack(s)"
	echo ""
}

while [[ $1 = -* ]]; do

	PARAM=$(echo $1 | awk -F= '{print $1}')

	case $PARAM in
	--module | -m)
		modules+="$2"
		;;
	-h | --help)
		usage
		exit 0
		;;
	-u | --update)
		STACK_COMMAND="update-stack"
                WAIT_COMMAND="stack-update-complete"
		;;
        *)
		echo "Unknown argument passed to this script."
		usage
		exit 1
		;;
	esac
	shift
done

if ! ((${#modules[@]})); then
	modules=("network" "permissions" "webservers" "ansible-master" "bastion-hosts")
fi

for i in "${modules[@]}"; do
        STACK_COMMAND="create-stack"
        WAIT_COMMAND="stack-create-complete"
        parameter_rel_filepath="${iac_source_path}/parameters_$i.json"
	parameters="file://${iac_source_path}/parameters_$i.json"
        
        if [ $i == "network" ]; then
                WAIT_CREATE_COMPLETED=true
        fi
        if [ $i == "permissions" ]; then
                STACK_COMMAND+=" $IAM_CAPABILITIES"
                WAIT_CREATE_COMPLETED=true
        fi
	if [ $i == "bastion-hosts" ]; then
		read -e -p "Enter your public IPv4 address " userIpV4
                #parameters_replaced=true
                #parameter_file_template=$parameter_file
                #parameter_file="${iac_source_path}/parameters_${i}_filled.json"
		#sed -e "s/TEMPLATE_MyCidrIpAddress/${userIpV4}/g" $parameter_file_template > $parameter_file 
                parameters=$(sed -e "s~TEMPLATE_MyCidrIpAddress~${userIpV4}~g" $parameter_rel_filepath | tr '\n' ' ')
                echo $parameters
	fi
        echo "aws cloudformation $STACK_COMMAND --stack-name $i --template-body "file://${iac_source_path}/cfn_$i.yml" --parameters $parameters --region eu-central-1"
        aws cloudformation $STACK_COMMAND --stack-name $1-$i --template-body "file://${iac_source_path}/cfn_$i.yml" --parameters "$parameters" --region eu-central-1

if $WAIT_CREATE_COMPLETED ; then
    aws cloudformation wait $WAIT_COMMAND --stack-name $1-$i
fi
done
