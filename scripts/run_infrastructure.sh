#!/bin/bash

# Don't redirect aws-cli output to editor
export AWS_PAGER=""

#Declare Variables
declare -a modules=()
IAM_CAPABILITIES=""
STACK_COMMAND_INITIAL="create-stack"
WAIT_CREATE_COMPLETED=false
IAM_CAPABILITIES="--capabilities CAPABILITY_NAMED_IAM"
DELETE=false
iac_source_path="../infrastructure-as-code"
WAIT_COMMAND="stack-create-complete"

declare -a modules=()

function usage() {
	echo "run_infastructure.sh [Flags]"
	echo ""
	echo "./manage_stack.sh"
	echo "  -h --help=Provision of help information"
	echo "  --update=Updates existing stack(s)"
	echo ""
}

while [[ $1 = -* ]]; do

	PARAM=$(echo "$1" | awk -F= '{print $1}')

	case $PARAM in
	-m | --module)
		modules+=("$2")
		echo "Module specification: $2 "
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	-d | --delete)
		DELETE=true
		WAIT_COMMAND="stack-delete-complete"
		echo "Deletion requested"
		shift 1
		;;
	-u | --update)
		STACK_COMMAND_INITIAL="update-stack"
		WAIT_COMMAND="stack-update-complete"
		echo "update requested"
		shift 1
		;;
	*)
		echo "Unknown argument passed to this script."
		usage
		exit 1
		;;
	esac
done

if ! ((${#modules[@]})); then
	if $DELETE; then
		modules=("bastion-hosts" "ansible-master" "webservers" "permissions" "network")
	else
		modules=("network" "permissions" "webservers" "ansible-master" "bastion-hosts")
	fi
fi

for i in "${modules[@]}"; do
	echo "Processing Module: $i"
	STACK_COMMAND=$STACK_COMMAND_INITIAL
	WAIT_CREATE_COMPLETED=false
	parameter_rel_filepath="${iac_source_path}/parameters_$i.json"
	parameters=$(sed -e "s~TEMPLATE_EnvironmentName~$1~g" "$parameter_rel_filepath" | tr '\n' ' ')
	if [ "$i" == "network" ]; then
		WAIT_CREATE_COMPLETED=true
	fi
	if [ "$i" == "permissions" ]; then
		STACK_COMMAND+=" $IAM_CAPABILITIES"
		WAIT_CREATE_COMPLETED=true
	fi

	if $DELETE; then
		aws cloudformation delete-stack --stack-name "$1"-"$i"
		aws cloudformation wait "$WAIT_COMMAND" --stack-name "$1"-"$i"
	else
		if [[ ($i == "bastion-hosts") || ($i == "jenkins-server") ]]; then
			# shellcheck disable=SC2162
			read -e -p "Enter your public IPv4 address " userIpV4
			# shellcheck disable=SC2001
			parameters=$(echo "$parameters" | sed -e "s~TEMPLATE_MyCidrIpAddress~${userIpV4}~g")
		fi
		if [[ ($i == "dns") ]]; then
			# shellcheck disable=SC2162
			read -e -p "Enter the first EnvironmentName " EnvNameInfrastrA
			# shellcheck disable=SC2001
			parameters=$(echo "$parameters" | sed -e "s~TEMPLATE_EnvNameInfrastrA~${EnvNameInfrastrA}~g")
			# shellcheck disable=SC2162
			read -e -p "Enter the first EnvironmentName " EnvNameInfrastrB
			# shellcheck disable=SC2001
			parameters=$(echo "$parameters" | sed -e "s~TEMPLATE_EnvNameInfrastrB~${EnvNameInfrastrB}~g")
		fi
		if [[ ($i == "webservers") || ($i == "ansible-master") || ($i == "bastion-hosts") || ($i == "jenkins-server") || ($i == "kubernetes-master") ]]; then
			# shellcheck disable=SC2162
			read -e -p "Enter the EC2 Key Name for the $i: " SshKeyName
			# shellcheck disable=SC2001
			parameters=$(echo "$parameters" | sed -e "s~TEMPLATE_SshKeyName~${SshKeyName}~g")
		fi
		echo "$parameters"
		# shellcheck disable=SC2086
		aws cloudformation ${STACK_COMMAND} --stack-name ${1}-${i} --template-body "file://${iac_source_path}/cfn_${i}.yml" --parameters "${parameters}" --region eu-central-1

		if $WAIT_CREATE_COMPLETED; then
			aws cloudformation wait "$WAIT_COMMAND" --stack-name "$1"-"$i"
		fi
	fi
done
