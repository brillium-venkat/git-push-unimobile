#!/bin/bash
# ====================================================================================================================================
# appbrahma-build-and-run-android.sh
# AppBrahma Android Unimobile App building and running
# Created by Venkateswar Reddy Melachervu on 16-11-2021.
# Updates:
# 	17-12-2021 - Added gracious error handling and recovery mechansim for already added android platform
#	26-12-2021 - Added error handling and android sdk path check
#	20-01-2022 - Created script for linux
#	29-01-2022 - Updated
#	27-02-2022 - Updated for streamlining exit error codes and re-organizing build code into a function for handling
#                dependency version incompatibilities
#	07-03-2022 - Updated for function exit codes, format and app display prefix
#	08-03-2022 - Synchronized with windows batch ejs file
#	12-03-2022 - Updated for installation checks and de-cluttering the console output by capturing the output into env variable
#	27-03-2022 - Unified http and https script files into one (Reference article - https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/)
#	22-03-2022 - Included support for android sdk api levels below 28 and above 28#
#	27-03-2022 - Unified http and https script files into one
#	05-06-2022 - Modifications for push notifications and android device connection
#	11-06-2022 - Linux and MacOS script unification
#	15-06-2022 - Unifying with windows batch script - user messages and logic rationalization
#	16-06-2022 - Optimizing of "add cap android platform" logic and removing the certificated related logic
#	18-06-2022 - New line fix in script error reporting
#	30-06-2022 - Update for sample push notification fix for package change
#	08-07-2022 - Sync up with windows script for generator name and screen vertical format
#	09-07-2022 - Update for unification across OSes and format
#
# 	(C) Brillium Technologies 2019-2022. All rights reserved.
# ===================================================================================================================================================

# color constants
export RED=$(tput setaf 9)
export GREEN=$(tput setaf 10)
export YELLOW=$(tput setaf 11)
export LIME_YELLOW=$(tput setaf 190)
export ORANGE=$(tput setaf 172)
export POWDER_BLUE=$(tput setaf 153)
export BLUE=$(tput setaf 4)
export PURPLE=$(tput setaf 141)
export MAGENTA=$(tput setaf 5)
export CYAN=$(tput setaf 6)
export WHITE=$(tput setaf 7)
export BRIGHT=$(tput bold)
export BLINK=$(tput blink)
export REVERSE=$(tput smso)
export UNDERLINE=$(tput smul)
export BOLD=$(tput bold)
export NT=$(tput sgr0)

export ERROR=$RED
export WARNING=$YELLOW
export ATTENTION=$WHITE
export SUCCESS=$GREEN
export INFO=$WHITE
export ACCENT=$CYAN

# Globes
UNIMO_APP_NAME="Git Push Unimobile"
MOBILE_GENERATOR_NAME="AppBrahma"
MOBILE_GENERATOR_LINE_PREFIX=\[$MOBILE_GENERATOR_NAME]

# Required version values
NODE_MAJOR_VERSION=16
NPM_MAJOR_VERSION=6
IONIC_CLI_MAJOR_VERSION=6
IONIC_CLI_MINOR_VERSION=16
JAVA_MIN_MAJOR_VERSION=11
JAVA_MIN_MINOR_VERSION=0

# cert deployment related
EXIT_CERT_DEPLOYER_EXIT_CODE_BASE=150
EXIT_ADB_EMULATOR_PATHS_ERROR=151
EXIT_COMMAND_ERROR_CODE=152
EXIT_ANDROID_HOME_PATH_COMMAND_ERROR_CODE=153
EXIT_ADB_DEV_LIST_COMMAND_ERROR_CODE=154
EXIT_EMULATOR_HELP_COMMAND_ERROR_CODE=155
EXIT_ADB_HELP_COMMAND_ERROR_CODE=156
EXIT_EMULATOR_LIST_AVDS_HELP_COMMAND_ERROR_CODE=157
EXIT_ADB_LIST_DEVICES_HELP_COMMAND_ERROR_CODE=158
EXIT_NO_DEVICE_CONNECTED_ERROR_CODE=159
EXIT_OPENSSL_NOT_IN_PATH_ERROR_CODE=160
EXIT_CERT_HASH_GEN_COMMAND_ERROR_CODE=161
EXIT_RUN_EMULATOR_COMMAND_ERROR_CODE=162
EXIT_RESTART_ADB_AS_ROOT_COMMAND_ERROR_CODE=163
EXIT_DISABLE_SECURE_ROOT_COMMAND_ERROR_CODE=164
EXIT_ADB_REBOOT_COMMAND_ERROR_CODE=165
EXIT_REMOUNT_PARTITIONS_COMMAND_ERROR_CODE=166
EXIT_PUSH_SIGNED_CERT_COMMAND_ERROR_CODE=167
EXIT_SET_CERT_PERMS_COMMAND_ERROR_CODE=168
EXIT_ADB_DEVICES_COMMAND_ERROR_CODE=169

# build and run related
EXIT_ERROR_CODE=200
EXIT_LINUX_VERSION_CHECK_COMMAND_ERROR_CODE=201
EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE=202
EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE=203
EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE=204
EXIT_JAVA_VERSION_CHECK_COMMAND_ERROR_CODE=205
EXIT_JDK_VERSION_CHECK_COMMAND_ERROR_CODE=206
EXIT_EMULATOR_HELP_COMMAND_ERROR_CODE=207
EXIT_NPM_INSTALL_COMMAND_ERROR_CODE=208
EXIT_IONIC_BUILD_COMMAND_ERROR_CODE=209
EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE=210
EXIT_UNIMO_INSTALL_BUILD_ERROR_CODE=211
EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD=212
EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE=213
EXIT_CORDOVA_RES_COMMAND_ERROR_CODE=214
EXIT_ADB_VERSION_COMMAND_ERROR_CODE=215
EXIT_IONIC_CAP_RUN_COMMAND_ERROR_CODE=216
EXIT_GET_SDK_API_LEVEL_ERROR_CODE=217
EXIT_ADB_REVERSE_COMMAND_ERROR_CODE=218
EXIT_WRONG_PARAMS_ERROR_CODE=219
EXIT_EMULATOR_LIST_AVDS_COMMAND_ERROR_CODE=220
EXIT_PROJ_REBUILD_ERROR_CODE=221
EXIT_PRE_REQ_CHECK_FAILURE_CODE=222
EXIT_CERT_DEPLOYMENT_PRE_REQ_CHECK_FAILURE_CODE=223
EXIT_CERT_DEPLOYMENT_FAILURE_CODE=224
EXIT_ANDROID_HOME_NOT_SET_CODE=225
EXIT_EMULATOR_EXE_PATH_NOT_PROPERLY_SET_CODE=226
EXIT_ANDROID_PLATFORM_TOOLS_NOT_IN_PATH_CODE=227
EXIT_ANDROID_SDK_TOOLS_NOT_SET_IN_PATH_CODE=228
EXIT_ANDROID_SDK_PATH_NOT_SET_IN_PATH_CODE=229
EXIT_IONIC_REINSTALL_CAP_ANDROID_PLATFORM=230
EXIT_CORDOVA_RES_ICON_CUSTOMIZE_ERROR_CODE=231
EXIT_IONIC_CAP_ANDROID_RUN_COMMAND_ERROR_CODE=232
EXIT_ADB_REVERSE_TCP_COMMAND_ERROR_CODE=233
EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE=234
EXIT_APB_FCM_JSON_FILE_COPY_ERROR_CODE=235
EXIT_SYNC_CAP_PROJECT_ERROR_CODE=236
EXIT_DIR_DELETE_COMMAND_ERROR_CODE=237

APPBRAHMA_CERT_DEPLOYMENT=1
THIRD_PARTY_CERT_DEPLOYED=2
INVALID_CERT_ISSUER_SELECTION=3
cap_android_platform_reinstall=0
target=""

# arguments and globals init
build_rebuild=$1
server_rest_api_mode=$2
expected_arg_count=2
build_type_all=0
build_type_android_platform_reinstall=1
build_type_redo_deps_build_cap_android_platform=2
unimo_build_type=$build_type_all
third_party_cert=0
BUILD="build"
REBUILD="rebuild"
HTTP="http"
HTTPS="https"
CAP_CLI_ERROR='Error while getting Capacitor CLI version'
PLATFORM_ALREADY_INSTALLED='android platform is already installed'

# function to delete android platform folders
remove_android_platform() {
	return_code=0
	remove_android_platform_and_www_dirs=$(rm -rf android www 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing android and www directories for fixing capacitor incompatibilities for android platform!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
		echo "$remove_android_platform_and_www_dirs"
		return_code=$EXIT_DIR_DELETE_COMMAND_ERROR_CODE
		return
  fi
}

# function common pre-reqs check
unimo_common_pre_reqs_validation() {
	return_code=0
	# OS version validation
	LINUX_VERSION_CMD=$(lsb_release -a 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error in getting linux version. The error is:${NT}"
		echo "$LINUX_VERSION_CMD"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting $MOBILE_GENERATOR_NAME unimobile app build and run script!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing above errors.${NT}"
		return_code=$EXIT_LINUX_VERSION_CHECK_COMMAND_ERROR_CODE
		return
	fi
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Your linux distribution name and version are:"
	echo "$LINUX_VERSION_CMD"

	# Node install check
	node_command=$(node --version 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Nodejs is not installed or NOT in PATH!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS version of nodejs major release $NODE_MAJOR_VERSION or fix the PATH and retry running this script.${NT}"
		return_code=$EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE
		return
	fi

	# Node version check
	node_version=$(node --version | awk -F. '{ print $1 }' 2>&1)
	# remove the first character
	node_command=${node_version#?}
	if [ $node_command -lt $NODE_MAJOR_VERSION ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported nodejs major version $(node --version | awk -F. '{ print $1 }')!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Supported major version is $NODE_MAJOR_VERSION${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS NodeJS version of major release $NODE_MAJOR_VERSION and retry running this script.${NT}"
		return_code=$EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE
		return
	else
	    	echo "$MOBILE_GENERATOR_LINE_PREFIX : Nodejs major version requirement - $NODE_MAJOR_VERSION - met. Moving ahead with other checks..."
	fi

	# npm install check
	npm_command=$(npm --version 2>&1)
	if [ $? -gt 0 ]; then
		    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : npm (Node Package Manager) is not installed or NOT in PATH!${NT}"
		    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS version of npm major release $NPM_MAJOR_VERSION or fix the PATH and retry running this script.${NT}"
		    return_code=$EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE
		    return
	fi

	# NPM version check
	npm_version=$(npm --version | awk -F. '{ print $1 }' 2>&1)
	if [ $npm_version -lt $NPM_MAJOR_VERSION ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running unsupported npm major version $(npm --version | awk -F. '{ print $1 }')!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Supported major version is $NPM_MAJOR_VERSION${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS npm version of major release $NPM_MAJOR_VERSION and retry running this script.${NT}"
		return_code=$EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE
		return
	else
	    	echo "$MOBILE_GENERATOR_LINE_PREFIX : npm major version requirement - $NPM_MAJOR_VERSION - met. Moving ahead with other checks..."
	fi

	# ionic install check
	ionic_command=$(ionic --version 2>&1)
	if [ $? -gt 0 ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Ionic CLI is not installed or not in PATH!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS version of ionic cli major release $IONIC_CLI_MAJOR_VERSION or fix the PATH and retry running this script.${NT}"
	    return_code=$EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	fi

	# ionic cli version validation
	ionic_cli_version=$(ionic --version | awk -F. '{ print $1 }')
	if [ $ionic_cli_version -lt $IONIC_CLI_MAJOR_VERSION ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running unsupported Ionic CLI major version $ionic_cli_version!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Supported major version is $IONIC_CLI_MAJOR_VERSION${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS Ionic CLI version of major release $IONIC_CLI_MAJOR_VERSION and retry running this script.${NT}"
	    return_code=$EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	else
	    echo "$MOBILE_GENERATOR_LINE_PREFIX : Ionic CLI major version requirement - $IONIC_CLI_MAJOR_VERSION - met. Moving ahead with other checks..."
	fi

	# java install check
	java_command=$(java -version 2>&1)
	if [ $? -gt 0 ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Java runtime is not installed or NOT in PATH!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS Java JDK version of major release $JAVA_MIN_MAJOR_VERSION or fix the PATH and retry running this script.${NT}"
	    return_code=$EXIT_JAVA_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	fi

	# java runtime version check
	java_version_first_part=$(java -version 2>&1 | awk 'NR==1 {print $3}'| awk -F. '{print $1}')
	java_version_first_part=$(echo $java_version_first_part | sed "s/\"//g")
	java_version_second_part=$(java -version 2>&1 | awk 'NR==1 {print $3}'| awk -F. '{print $2}')
	if [ $java_version_first_part -lt $JAVA_MIN_MAJOR_VERSION -a $java_version_second_part -lt $JAVA_MIN_MAJOR_VERSION ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running unsupported Java runtime version $java_version_second_part!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Supported major version is $JAVA_MIN_MAJOR_VERSION${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS version of Java/JDK major release $JAVA_MIN_MAJOR_VERSION or fix the PATH and retry running this script.${NT}"
	    return_code=$EXIT_JAVA_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	else
	    echo "$MOBILE_GENERATOR_LINE_PREFIX : Java runtime version requirement - $JAVA_MIN_MAJOR_VERSION - met. Moving ahead with other checks..."
	fi

	# jdk install check
	jdk_command=$(javac -help 2>&1)
	if [ $? -gt 0 ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Java JDK is not installed or NOT in PATH!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS Java JDK version of major release $JAVA_MIN_MAJOR_VERSION or fix the PATH and retry running this script.${NT}"
	    return_code=$EXIT_JDK_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	else
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Java JDK found in the path. Moving ahead with other checks..."
	fi

	# android environment variables check - android_home, platform-tools, emulator, tools\bin
	android_home=$(echo $ANDROID_HOME | grep -iF "android/sdk" 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : ANDROID_HOME environment varible is not set!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please set this variable value - usually $HOME/Android/Sdk - and retry running this script.${NT}"
		return_code=$EXIT_ANDROID_HOME_NOT_SET_CODE
		return
	fi

	android_sdk_path=$(echo $PATH | grep -iF "android/sdk" 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Android SDK path is NOT set in PATH environment variable!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please set this path value - usually $HOME/Android/Sdk - and retry running this script.${NT}"
		return_code=$EXIT_ANDROID_SDK_PATH_NOT_SET_IN_PATH_CODE
		return
	fi

	android_sdk_platform_tools_path=$(echo $PATH | grep -iF "android/sdk/platform-tools" 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Android SDK Platform tools path is NOT set in PATH environment variable!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please set this path value - usually $HOME/Android/Sdk/platform-tools - and retry running this script.${NT}"
		return_code=$EXIT_ANDROID_PLATFORM_TOOLS_NOT_IN_PATH_CODE
		return
	fi

	android_emulator_path=$(echo $PATH | grep -iF "android/sdk/emulator" 2>&1)
	if [ $? -gt 0 ]; then
		emu_path=$(which emulator)
		if [[ $? -ne 0 ]]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Android emulator is NOT installed or executable path is NOT set in PATH environment variable!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Usually the relevant path is $HOME/Android/Sdk/emulator/emulator${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install or set the emulator path in PATH and retry running this script.${NT}"
			return_code=$EXIT_EMULATOR_EXE_PATH_NOT_PROPERLY_SET_CODE
		else
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Currently android emulator executable path is set to $emu_path in PATH environment variable which is not relevant for this script!"
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Usually the relevant path is $HOME/Android/Sdk/emulator/emulator"
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Please install or set the relevant emulator path in PATH and retry running this script."
			return_code=$EXIT_EMULATOR_EXE_PATH_NOT_PROPERLY_SET_CODE
		fi
		return
	fi

	android_sdk_tools_path=$(echo $PATH | grep -iF "android/sdk/tools/bin" 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Android SDK tools is NOT installed or its path is NOT set in PATH environment variable!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install or set this path value - usually $HOME/Android/Sdk/tools/bin - and retry running this script.${NT}"
		return_code=$EXIT_ANDROID_SDK_TOOLS_NOT_SET_IN_PATH_CODE
		return
	fi

	# adb command check
	android_adb_command_check=$(adb --version 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : adb command executable path is not found. Either android SDK tools not installed or adb executable path is NOT set in PATH!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install the same and/or set the PATH variable and retry running this script.${NT}"
		return_code=$EXIT_ADB_VERSION_COMMAND_ERROR_CODE
		return
	else
		echo "$MOBILE_GENERATOR_LINE_PREFIX : adb executable is found to be in the PATH. Moving ahead with other checks..."
	fi

	# emulator command check
	android_emulator_command_check=$(emulator -help 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Emulator command executable path is not found. Either android SDK tools not installed or emulator executable path is NOT set in PATH!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install the same and/or set the PATH variable and retry running this script.${NT}"
		return_code=$EXIT_EMULATOR_HELP_COMMAND_ERROR_CODE
		return
	else
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Emulator executable is found to be in the PATH. Continuing ahead..."
	fi

	# at least one AVD should be configured
	android_emulator_avds=$(emulator -list-avds 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error getting the configured AVDs!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : The error details are:${NT}"
		echo "$android_emulator_avds"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please fix emulator command execution errors displayed above and retry running this script.${NT}"
		return_code=$EXIT_EMULATOR_LIST_AVDS_COMMAND_ERROR_CODE
		return

	fi
	avds=$(emulator -list-avds | wc -l 2>&1)
	avds="${avds## }"
	avds="${avds%% }"
	if [ $avds -lt 1 ]; then
		echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Not a single android virtual device - AVD - or Emulator image is set up!${NT}"
		echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : If you want to run the unimobile app on emulator, please abort this script execution right now by pressing Ctrl+C, configure at least one AVD and retry running this script.${NT}"
    echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Else, if you would like to run the Unimobile app directly on a connected android device, please ensure an android device is connected and USB debug options are enabled on thE device and then proceed ahead.${NT}"
    # wait for the user confirmation
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue after connecting and setting up android device to this computer...${NT}"
	else
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Found $avds AVDs configured for the emulator."
	fi

	# connected devices check
  	phones=$(adb devices | awk 'NR>1' | awk -F' ' '{ print $1 }' 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error getting the connected devices!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : The error details are:${NT}"
		echo "$phones"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please fix errors displayed above and retry running this script.${NT}"
		return_code=$EXIT_ADB_DEVICES_COMMAND_ERROR_CODE
		return

	fi
	phones="${phones## }"
	phones="${phones%% }"
	if [ -z $phones ]; then
		# no connected devices
      	if [ $avds -lt 1 ]; then
        	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Not a single connected android device nor an AVD found!${NT}"
        	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please set up at least one AVD or connect an android device and retry running this script.${NT}"
        	return_code=$EXIT_ADB_DEVICES_COMMAND_ERROR_CODE
			return
      	fi
  	else
    	echo "$MOBILE_GENERATOR_LINE_PREFIX : Found connected android device(s) : $phones."
  	fi
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Pre-requisites validation completed successfully."
}

# function to re-install node deps
npm_reinstall() {
	return_code=0
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Now re-installing nodejs dependencies..."
	NPM_INSTALL_DEPS_COMMAND_RES=$(npm install --force 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Re-attempt to install node dependencies resulted in error!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
		echo "$NPM_INSTALL_DEPS_COMMAND_RES"
        echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing these issues.${NT}"
		return_code=$EXIT_NPM_INSTALL_COMMAND_ERROR_CODE
		return
	else
		return_code=0
	fi
}

# function to install node dependencies
npm_install() {
	return_code=0
	NPM_INSTALL_DEPS_COMMAND_RES=$(npm install --force 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error installing node dependencies!${NT}"
		echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Diagnosing and fixing the errors...${NT}"
		delete_node_modules=$(rm -rf node_modules 2>&1)
		if [[ $? -ne 0 ]]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing node_modules directory for fixing dependencies install errors!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting the execution.${NT}"
			echo "$delete_node_modules"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
			return_code=$EXIT_NPM_INSTALL_COMMAND_ERROR_CODE
			return
		else
			npm_reinstall
			if [[ $? -ne 0 ]]; then
				return
			fi
		fi
	fi
}

# function to build the project
ionic_build() {
	return_code=0
	ionic_build_command_res=$(ionic build 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error building unimobile app project!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
		echo "$ionic_build_command_res"
        echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
		return_code=$EXIT_IONIC_BUILD_COMMAND_ERROR_CODE
		return
	fi
}

# function to add capacitor android platform
add_cap_platform() {
    return_code=0
	ADD_CAPACITOR_ANDROID_PLATFORM_COMMAND_RES=$(ionic cap add android 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Found issues in adding android platform!${NT}"
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Diagnosing for the root cause..."

		case $ADD_CAPACITOR_ANDROID_PLATFORM_COMMAND_RES in
		# check for any capacitor cli version in-compatibility error. If so, delete node_modules and run a fresh build using the same script
		*"$CAP_CLI_ERROR"*)
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Capacitor version incompatibilities found. Fixing the incompatibilities..."
			remove_android_platform_and_node_deps_res=$(rm -rf android node_modules www 2>&1)
			if [[ $? -ne 0 ]]; then
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing node_modules, android, and www directories for fixing capacitor incompatibilities for android platform!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
				echo "$remove_android_platform_and_node_deps_res"
				return_code=$EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE
				return
			else
				unimo_build_type=$build_type_redo_deps_build_cap_android_platform
				return_code=$EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD
				return
			fi
		;;
		# if the android platform was already installed, sync it
		*"$PLATFORM_ALREADY_INSTALLED"*)
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Android platform was already added!"
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronizing capacitor android platform..."
			# remove_android_platform_command_res=$(rm -rf android 2>&1)
			synchronize_cap_android_res=$(ionic cap sync android 2>&1)
			if [[ $? -ne 0 ]]; then
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error synchronizing android platform!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
				echo "$synchronize_cap_android_res"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
				return_code=$EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE
				return
			else
				echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Synchronized capacitor android platform.${NT}"
				return_code=0
				return
			fi
		;;
		esac
	else
		echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Added capacitor android platform.${NT}"
		return_code=0
		return
	fi
}

# function to build unimo app
unimo_install_ionic_deps_build_and_platform() {
	# check the type of action to take for it could have been a nested call
	if [[ $unimo_build_type -eq $build_type_android_platform_reinstall ]]; then
		# any special handling for re-adding cap android platform
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Now re-adding capacitor android platform..."
		add_cap_platform
		if [[ $return_code -ne 0 ]]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error re-adding capacitor android platform!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting Unimobile build and run process.${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing above reported errors.${NT}"
			return_code=$EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE
			return
		else
			# sync it after adding the platform
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronizing capacitor android platform..."
			synchronize_cap_android_res=$(ionic cap sync android 2>&1)
			if [[ $? -ne 0 ]]; then
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error synchronizing android platform!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
				echo "$synchronize_cap_android_res"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
				return_code=$EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE
				return
			else
				# echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronized capacitor android platform."
				return_code=0
				return
			fi
		fi

	fi

	if [[ $unimo_build_type -eq $build_type_redo_deps_build_cap_android_platform ]]; then
		# any special handling for redoing the deps and build
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Re-building the unimobile app..."
	fi

	if [[ $unimo_build_type -eq $build_type_all ]]; then
		# any special handling for build all
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Building the unimobile app..."
	fi

	echo "$MOBILE_GENERATOR_LINE_PREFIX : Now installing node dependencies..."
	npm_install
	if [[ $return_code -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error installing node dependencies!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Please fix these issues and re-run this script.${NT}"
		return_code=$EXIT_NPM_INSTALL_COMMAND_ERROR_CODE
		return
	fi
	echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Installed node dependencies.${NT}"

	echo "$MOBILE_GENERATOR_LINE_PREFIX : Now building the project..."
	ionic_build
	if [[ $return_code -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error building the project!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Please fix these issues and re-run this script.${NT}"
		return_code=$EXIT_IONIC_BUILD_COMMAND_ERROR_CODE
		return
	fi
	echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Project built successfully.${NT}"

	echo "$MOBILE_GENERATOR_LINE_PREFIX : Now adding capacitor android platform..."
	add_cap_platform
	case $return_code in
		$EXIT_IONIC_REINSTALL_CAP_ANDROID_PLATFORM)
			unimo_build_type=$build_type_android_platform_reinstall
			unimo_install_ionic_deps_build_and_platform
			if [[ $return_code -ne 0 ]]; then
				# any needed error handling
				return
			fi
			return
		;;

		$EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD)
			unimo_build_type=$build_type_redo_deps_build_cap_android_platform
			unimo_install_ionic_deps_build_and_platform
			if [[ $return_code -ne 0 ]]; then
				# any needed error handling
				return
			fi
			return
		;;

		0)
			# echo "$MOBILE_GENERATOR_LINE_PREFIX : Added capacitor android platform."
			return_code=0
			return
		;;

		*)
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error adding android capacitor platform!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Please fix these issues and re-run this script.${NT}"
			return_code=$EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE
			return
		;;
	esac
}

resync_android_platform_after_fcm_files() {
  # remove android platfor and www dirs
  delete_dir=$(rm -rf android www 2>&1)
  if [ $? -gt 0 ]; then
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing android and www directories for re-building the project!${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting the execution.${NT}"
    echo "$delete_dir"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
    $return_code=$EXIT_PROJ_REBUILD_ERROR_CODE
    return
  else
    echo "$MOBILE_GENERATOR_LINE_PREFIX : Removed android and www directories for re-building the project."
    read -p "$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue..."
  fi

  # call ionic build with deps
  unimo_build_type=$build_type_redo_deps_build_cap_android_platform
  unimo_install_ionic_deps_build_and_platform
  if [[ $return_code -ne 0 ]]; then
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error re-building Unimobile project and adding android platform!${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
    $return_code=$EXIT_SYNC_CAP_PROJECT_ERROR_CODE
    return
  fi

  echo "$MOBILE_GENERATOR_LINE_PREFIX : Re-customising Unimobile application icon and splash images..."
  customize_app_icons_res=$(cordova-res android --skip-config --copy 2>&1)
  if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error re-customising the application icon and splash images!${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are:${NT}"
    echo "$customize_app_icons_res"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the execution. Please retry running this script after fixing the above reported issues.${NT}"
    return_code=$EXIT_CORDOVA_RES_ICON_CUSTOMIZE_ERROR_CODE
    return
  fi
  echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Re-customised Unimobile application icon and splash images.${NT}"
}

# main script
# clear the screen for visibility
clear

echo "=============================================================================================================================================================="
echo "		Welcome to ${GREEN}${BOLD}$UNIMO_APP_NAME build and run script generated by ${GREEN}$MOBILE_GENERATOR_NAME - the baap of apps${NT}"
echo "Sit back, relax, and sip a cuppa coffee while the dependencies are downloaded, project is built, and run."
echo "${YELLOW}Unless the execution of this script stops, do not be bothered nor worried about any warnings or errors displayed during the execution$NT"
echo "-Team AppBrahma"
echo "=============================================================================================================================================================="
echo "${BOLD}${YELLOW}$MOBILE_GENERATOR_LINE_PREFIX : You typed - $0 $*${NT}"

# arguments
# $1 - build/rebuild - rebuild cleans the target directory, node_modules etc. forcibly
# $2 - http/https - Unimobile app server protocol support - http or https

# globbed return value used by functions
return_code=0

if [ "$#" -ne $expected_arg_count ]; then
	echo "${ERROR}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : In-sufficient or invalid arguments supplied -needed $expected_arg_count but "$#" supplied!${NT}"
	echo "${BOLD}Usage:${NT}"
	echo "  $0 ${BOLD}<build_task_type> <server_protocol>${NT}"
	echo "${BOLD}Arguments:${NT}"
	echo "  ${BOLD}${GREEN}build-task-type${NT}:"
	echo "    - Build or rebuild. Rebuild cleans the target forcibly."
	echo "    - Mandatory argument. Allowed values - ${BOLD}${GREEN}build${NT} or ${BOLD}${GREEN}rebuild${NT}."
	echo "  ${BOLD}${GREEN}server-protocol${NT}:"
	echo "    - Backend server protocol. HTTP is NOT auto-redirected to HTTPS."
  echo "    - Mandatory argument. Allowed values - ${BOLD}${GREEN}http${NT} or ${BOLD}${GREEN}https${NT}."
	exit $EXIT_WRONG_PARAMS_ERROR_CODE
fi

# args validation
if [[ $build_rebuild != $BUILD && $build_rebuild != $REBUILD ]]; then
	echo "${ERROR}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Invalid value - \"$build_rebuild\" - supplied to the first argument!${NT}"
	echo "${BOLD}Usage:${NT}"
	echo "  $0 ${BOLD}<build_task_type> <server_protocol>${NT}"
	echo "${BOLD}Arguments:${NT}"
	echo "  ${BOLD}${GREEN}build-task-type${NT}:"
	echo "    - Build or rebuild. Rebuild cleans the target forcibly."
	echo "    - Mandatory argument. Allowed values - ${BOLD}${GREEN}build${NT} or ${BOLD}${GREEN}rebuild${NT}."
	echo "  ${BOLD}${GREEN}server-protocol${NT}:"
	echo "    - Backend server protocol. HTTP is NOT auto-redirected to HTTPS."
  echo "    - Mandatory argument. Allowed values - ${BOLD}${GREEN}http${NT} or ${BOLD}${GREEN}https${NT}."
	exit $EXIT_WRONG_PARAMS_ERROR_CODE
fi
if [[ $server_rest_api_mode != $HTTP && $server_rest_api_mode != $HTTPS ]]; then
	echo "${ERROR}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Invalid value - \"$server_rest_api_mode\" - supplied to the second argument!${NT}"
	echo "${BOLD}Usage:${NT}"
	echo "  $0 ${BOLD}<build_task_type> <server_protocol>${NT}"
	echo "${BOLD}Arguments:${NT}"
	echo "  ${BOLD}${GREEN}build-task-type${NT}:"
	echo "    - Build or rebuild. Rebuild cleans the target forcibly."
	echo "    - Mandatory argument. Allowed values - ${BOLD}${GREEN}build${NT} or ${BOLD}${GREEN}rebuild${NT}."
	echo "  ${BOLD}${GREEN}server-protocol${NT}:"
	echo "    - Backend server protocol. HTTP is NOT auto-redirected to HTTPS."
  echo "    - Mandatory argument. Allowed values - ${BOLD}${GREEN}http${NT} or ${BOLD}${GREEN}https${NT}."
	exit $EXIT_WRONG_PARAMS_ERROR_CODE
fi

if [ "$build_rebuild" == "rebuild" ]; then
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Rebuild is requested. Cleaning the project for the rebuild..."
	if [ -d "node_modules" ]; then
		delete_dir=$(rm -rf "node_modules" 2>&1)
		if [ $? -gt 0 ]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing node_modules directory for rebuilding!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting the execution.${NT}"
			echo "$delete_dir"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
			exit $EXIT_DIR_DELETE_COMMAND_ERROR_CODE
		fi
	fi
	if [ -d "android" ]; then
		delete_dir=$(rm -rf "android" 2>&1)
		if [ $? -gt 0 ]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing android directory for rebuilding!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting the execution.${NT}"
			echo "$delete_dir"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
			exit $EXIT_DIR_DELETE_COMMAND_ERROR_CODE
		fi
	fi
	if [ -d "www" ]; then
		delete_dir=$(rm -rf "www" 2>&1)
		if [ $? -gt 0 ]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing www directory for rebuilding!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting the execution.${NT}"
			echo "$delete_dir"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
			exit $EXIT_DIR_DELETE_COMMAND_ERROR_CODE
		fi
	fi
	echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Unimobile project successfully cleaned.${NT}"
fi

echo "$MOBILE_GENERATOR_LINE_PREFIX : Validating pre-requisites..."
unimo_common_pre_reqs_validation
if [[ $return_code -ne 0 ]]; then
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Pre-requisites validation failed!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the execution.${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the above reported errors.${NT}"
	exit $EXIT_PRE_REQ_CHECK_FAILURE_CODE
fi
# prompt user to copy google-services.json file for FCM push notifications to under capacitor android project directory - android\app\ in ionic project root
echo "${YELLOW}$MOBILE_GENERATOR_LINE_PREFIX : This Unimobile app is generated with out-of-the-box push notifications implementation using Firebase Cloud Messaging by AppBrahma MVP Generator Service.${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : There are a couple of pre-requisites, listed below, that needs to be fulfilled for building and running the Unimobile app successfully with push notifications.${NT}"
echo "	1.Set-up Firebase Cloud Messaging for push notification in firebase console for this android app, and download google-services.json file - Reference: https://console.firebase.google.com${NT}"
echo "	2.Copy this .json file to <unimobile_project_root>\android\app directory. You would be prompted for this after the project is built.${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please be aware that the Unimobile mobile application will crash at the start up, if you do not perform the above steps!${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Alternatively, for quick app testing, you can use AppBrahma generated sample FCM google-services.json and change the appID temporarily to sample appID.${NT}"

# prompt user for selection
use_configured_info="Use already configured FCM push notification info"
psj_selection=('Yes' 'No - I will set up FCM and download google.json file' "$use_configured_info")
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Would you like to use AppBrahma generated sample FCM information for push notifications?${NT}"
PS3='Please type a number shown above for selecting your option: '
select psj_user_selection in "${psj_selection[@]}";
do
  echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You have chosen \"$REPLY) $psj_user_selection\" as the option.${NT}"
  if [[ "$psj_user_selection" != "" ]]; then
      break
  fi
done
case $psj_user_selection in
  # user chose to use AppBrahma generated sample appID FCM files and info
  *"Yes"*)
    echo "${YELLOW}$MOBILE_GENERATOR_LINE_PREFIX : Change the appID value to \"com.brillium.unimobile.pn.demo\" in capacitor.config.ts in the unimobile root folder <unimobile_project_root>${NT}"
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue, after completing the above step...${NT}"
	remove_android_platform
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing android platform for updating the project!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
		exit $EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE
	fi
  ;;
  # user chose to generate FCM files and configure himself
  *"No"*)
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue after downloading the google-services.json file...${NT}"
    echo "$MOBILE_GENERATOR_LINE_PREFIX : You will be prompted to copy this file to <unimobile_project_root>/android/app/ folder after building ionic project."
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue...${NT}"
	remove_android_platform
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing android platform for updating the project!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
		exit $EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE
	fi
  ;;
  # user chose to use already configured FCM files and info
  *"$use_configured_info"*)
    # nothing more to do
  ;;
esac

echo "$MOBILE_GENERATOR_LINE_PREFIX : Unimobile app will be built and run for communicating with back-end server using $server_rest_api_mode protocol."
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please modify and ensure the web protocol in \"apiUrl\" key value to \"$server_rest_api_mode\" in src/environments/environment.ts of"
echo "Unimobile sources project directory and save the file to proceed further.${NT}"
echo "	Example 1 - apiUrl: '$server_rest_api_mode://192.168.0.114:8091/api'"
echo "	Example 2 - apiUrl: '$server_rest_api_mode://localhost:8091/api'"
read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue after modification and saving the file...${NT}"

# let us ensure nested call to below function does not race around
unimo_build_type=$build_type_all
unimo_install_ionic_deps_build_and_platform
if [[ $return_code -ne 0 ]]; then
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error in building Unimobile project and adding android platform!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
	exit $return_code
fi

# FCM google-services.json file copy
case $psj_user_selection in
  # user chose to use AppBrahma generated sample appID FCM files and info
  *"Yes"*)
    echo "$MOBILE_GENERATOR_LINE_PREFIX : Copying AppBrahma generated google-services.json from <unimobile_project_root>/unimobile/samples/push-notifications/android folder to <unimobile_project_root>/android/app/..."
    copy_fcm_pn_json=$(cp -f "unimobile/samples/push-notifications/android/google-services.json" "android/app/" 2>&1)
    if [ $? -ne 0 ]; then
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error copying AppBrahma generated sample google-services.json file. Error details are displayed below. Aborting the execution.${NT}"
      echo "$copy_fcm_pn_json"
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Fix the above errors and retry running this script.${NT}"
      exit $EXIT_APB_FCM_JSON_FILE_COPY_ERROR_CODE
    fi
    echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : AppBrahma generated sample google-services.json copied successfully.${NT}"
  ;;
  # user chose to generate FCM files and configure himself
  *"No"*)
    echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : As you chose to generate FCM files yourself for this Unimobile app, please complete the step of copying the downloaded google-json.json file to <unimobile_project_root>/android/app/ now.${NT}"
    echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please be aware that the Unimobile mobile application will crash at the start up, if you do not perform the above step!${NT}"
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue after completing the above step...${NT}"
  ;;
  # user chose to use already configured FCM files and info
  *"$use_configured_info"*)
    # nothing more to do
  ;;
esac

# cordova-res install check -global
echo "$MOBILE_GENERATOR_LINE_PREFIX : Checking for cordova-res node module which is needed for Unimobile app icon and splash customisation."
cordova_res_global_install_check_res=$(npm list -g cordova-res 2>&1)
if [[ $? -ne 0 ]]; then
	echo "$MOBILE_GENERATOR_LINE_PREFIX : cordova-res node module is not installed globally. This is needed for Unimobile app icon and splash customisation."
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Installing cordova-res..."
	cordova_global_install_res=$(npm install -g cordova-res 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error installing cordova-res node module!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are:${NT}"
		echo "$cordova_global_install_res"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the execution. Please retry running this script after fixing the above reported issues.${NT}"
		exit $EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE
	fi
else
  echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : cordova-res node module is installed and available.${NT}"
fi

echo "$MOBILE_GENERATOR_LINE_PREFIX : Customising Unimobile application icon and splash images..."
customize_app_icons_res=$(cordova-res android --skip-config --copy 2>&1)
if [[ $? -ne 0 ]]; then
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error customising the application icon and splash images!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are:${NT}"
	echo "$customize_app_icons_res"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the execution. Please retry running this script after fixing the above reported issues.${NT}"
	exit $EXIT_CORDOVA_RES_ICON_CUSTOMIZE_ERROR_CODE
fi
echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Customised Unimobile application icon and splash images."

# device select menu - check for any running emulator and take it out if found from the adb devices output
running_emulator="emulator"
phones=$(adb devices | awk 'NR>1' | awk -F' ' '{ print $1 }' 2>&1)
non_running_devices=$(echo "$phones" | while IFS= read -r line; do
  if [[ "$line" =~ .*"$running_emulator".* ]]; then
    echo ""
  else
    echo "$line "
  fi
done 2>&1)
avds=$(emulator -list-avds 2>&1)
devices="$non_running_devices $avds"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Which device would you like to target?${NT}"
PS3='Please type the AVD/device number shown above for selecting the target to run this Unimobile app on: '
select target in $devices;
do
	echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You have chosen \"$REPLY) $target\" as the target${NT}"
	if [[ "$target" != "" ]]; then
		break
	fi
done

# https check
if [[ "$server_rest_api_mode" == "https" ]]; then
	echo "${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : You have chosen https for back-end server protocol. For https support by Android apps, a signed server certificate needs to be deployed onto back-end server.${NT}"
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please ensure back-end server is deployed with a publicly known CA signed server certificate or a self-signed server certificate.${NT}"
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : If you are deploying self-signed (with or without CA) certificate, please ensure you've deployed the back-end server's self-signed certificate onto the device you are targeting.${NT}"
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Google link for certificate deployment steps: https://support.google.com/pixelphone/answer/2844832?hl=en"
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Link for self-signed server certificate deployment:  https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/"
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please be aware that a self-signed or non-public CA signed back-end server certificate may require special certificate store/trust configurations on iOS and Android devices for enabling HTTPS access to this server from Apps running on these devices - especially Unimobile app you might have generated for this server by AppBrahma MVP generator.${NT}"
	read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue, after completing the above steps...${NT}"
fi

echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronizing android platform..."
synchronize_cap_android_res=$(ionic cap sync android 2>&1)
if [[ $? -ne 0 ]]; then
	echo "${RED}$MOBILE_GENERATOR_LINE_PREFIX : Error synchronizing android platform!${NT}"
	echo "${RED}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
	echo "$synchronize_cap_android_res"
	echo "${RED}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
	return_code=$EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE
	return
else
	echo "${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Synchronized capacitor android platform.${NT}"
fi

echo "$MOBILE_GENERATOR_LINE_PREFIX : Starting build and run process of Unimobile app for the target $target with $server_rest_api_mode support..."
ionic_cap_run_android_command_res=$(ionic cap run android --target $target 2>&1)
if [[ $? -ne 0 ]]; then
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error running Unimobile app on the selected target!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
	echo "$ionic_cap_run_android_command_res"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the above reported issues.${NT}"
	exit $EXIT_IONIC_CAP_ANDROID_RUN_COMMAND_ERROR_CODE
fi

# configure emulator avd/device to access the server port, if running on localhost
echo "$MOBILE_GENERATOR_LINE_PREFIX : Configuring AVD/device to access the Appbrahma server running on localhost..."
adb_reverse_tcp_command_res=$(adb reverse tcp:8091 tcp:8091  2>&1)
if [[ $? -ne 0 ]]; then
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error confuguring android emulator to access the server running on localhost!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are:${NT}"
	echo "$adb_reverse_tcp_command_res"
	echo "${YELLOW}$MOBILE_GENERATOR_LINE_PREFIX : Please try executing the command - \"adb reverse tcp:8091 tcp:8091\" - for establishing seamless web connection between server running on localhost and this Unimobile app running on selected target.${NT}"
	read -p "${YELLOW}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue, after completing the above step...${NT}"
else
	echo "${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Configured AVD/device to access the Appbrahma server running on localhost...${NT}"
fi
# display credentials for log in - for server integrated template
echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : After the Unimobile app opens on the target you have selected:${NT}"
echo "	1.Run the backend server in a seperate console using AppBrahma build and run script, if it is AppBrahma generated back-end server."
echo "	2.Use the below user credentials to log in from Unimobile app to the back-end server"
echo ${YELLOW}- Admin user - Username: brahma, Password: brahma@appbrahma${NT}
echo ${YELLOW}- End user - Username: manasputhra, Password: manasputhra@appbrahma${NT}
echo ""
# acknowledgement and best wishes
echo "${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Wishing you best for faster quality development sprint cycles and go-live.${NT}"
echo ""
echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Powered and brought to you by the passion, perseverance, and pursuit of efficiency by Brillium Technologies to transform the world through technology.${NT}"
echo ""
echo "${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Thank you for giving us the opportunity to serve you in going live quickly with your MVP by cutting down your development time and effort of the first runnable version of your full-stack product from months of team work to a few individual clicks.${NT}"
echo "${GREEN}	-Team AppBrahma${NT}"
echo ""
read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key when ready to test your Unimobile app on the selected target...${NT}"
