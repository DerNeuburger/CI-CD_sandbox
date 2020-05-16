#!/bin/bash

# Don't redirect aws-cli output to editor
export AWS_PAGER=""

#Declare Variables
declare -a modules=()
IAM_CAPABILITIES=""
WAIT_CREATE_COMPLETED=false
EXTRA_PARAM=""
IAM_CAPABILITIES="--capabilities CAPABILITY_NAMED_IAM"
DELETE=false
update=""
iac_source_path="../infrastructure-as-code"
extra_parameters=""
parameters_replaced=false
WAIT_COMMAND="stack-create-complete"

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
	-m | --module)
		modules+="$2"
		echo "module $2 given"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	-d | --delete)
		DELETE=true
		WAIT_COMMAND="stack-delete-complete"
		echo "delete given"
		shift 1
		;;
	-u | --update)
		STACK_COMMAND="update-stack"
		WAIT_COMMAND="stack-update-complete"
		echo "update given"
		;;
	*)
		echo "Unknown argument passed to this script."
		usage
		exit 1
		;;
	esac
done

if ! ((${#modules[@]})); then
	modules=("network" "permissions" "webservers" "ansible-master" "bastion-hosts")
fi

for i in "${modules[@]}"; do
	STACK_COMMAND="create-stack"
	WAIT_CREATE_COMPLETED=false
	parameter_rel_filepath="${iac_source_path}/parameters_$i.json"
	parameters="file://${iac_source_path}/parameters_$i.json"

	if [ $i == "network" ]; then
		WAIT_CREATE_COMPLETED=true
	fi
	if [ $i == "permissions" ]; then
		STACK_COMMAND+=" $IAM_CAPABILITIES"
		WAIT_CREATE_COMPLETED=true
	fi

	if $DELETE; then
		aws cloudformation delete-stack --stack-name $1-$i
		aws cloudformation wait $WAIT_COMMAND --stack-name $1-$i
	else
		if [[ ($i == "bastion-hosts") || ($i == "jenkins-server") ]]; then
			read -e -p "Enter your public IPv4 address " userIpV4
			#parameters_replaced=true
			#parameter_file_template=$parameter_file
			#parameter_file="${iac_source_path}/parameters_${i}_filled.json"
			#sed -e "s/TEMPLATE_MyCidrIpAddress/${userIpV4}/g" $parameter_file_template > $parameter_file
			parameters=$(echo $parameters | sed -e "s~TEMPLATE_MyCidrIpAddress~${userIpV4}~g")
		fi
		echo $parameters
		aws cloudformation $STACK_COMMAND --stack-name $1-$i --template-body "file://${iac_source_path}/cfn_$i.yml" --parameters "$parameters" --region eu-central-1

		if $WAIT_CREATE_COMPLETED; then
			aws cloudformation wait $WAIT_COMMAND --stack-name $1-$i
		fi
	fi
done
