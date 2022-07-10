#!/bin/sh
# ==========================================================================================================================
# appbrahma-build-and-run-ios.sh
# AppBrahma iOS Unimobile App building and running
# Created by Venkateswar Reddy Melachervu on 16-11-2021.
# Updates:
#	17-12-2021 - Added gracious error handling and recovery mechansim for already added ios platform
#   29-01-2022 - Updated for ionic checks
#   27-02-2022 - Updated for streamlining exit error codes and re-organizing build code into a function for handling 
#                dependency version incompatibilities
#   07-03-2022 - Updated for function exit codes, format and app display prefix
#   08-03-2022 - Synchronized with windows batch ejs file
#   12-03-2022 - Updated for installation checks and de-cluttering the console output by capturing the output into env variable
#   21-03-2022 - Updated for combining http and https REST API support for unimobile to backend server communication
#	27-03-2022 - Unified http and https script files into one
#   08-06-2022 - Modifications for push notifications and ios device connection and unifying linux, mac and windows scripts
#	15-06-2022 - Optimizing of "add cap android platform" logic and removing the certificated related logic
#	18-06-2022 - New line fix in script error reporting
#	30-06-2022 - Update for sample push notification fix for package name change
#	08-07-2022 - Sync up with windows script for generator name and screen vertical format
#	09-07-2022 - Update for unification across OSes and format
#
# 	(C) Brillium Technologies 2011-2022. All rights reserved.
# =======================================================================================================================

# color constants
export RED=$(tput setaf 9)
export GREEN=$(tput setaf 10)
# export YELLOW=$(tput setaf 11)
export YELLOW=$(tput setaf 214)
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
GENERATOR_NAME="AppBrahma"
MOBILE_GENERATOR_LINE_PREFIX=\[$GENERATOR_NAME]

#ios related
OS_MAJOR_VERSION=10
OS_MINOR_VERSION=0
OS_PATCH_VERSION=1
XCODE_MAJOR_VERSION=12
XCODE_MINOR_VERSION=0
XCODE_PATCH_VERSION=1
XCODE_SELECT_MIN_VERSION=2300
COCOAPODS_MAJOR_VERSION=1

# Required version values
NODE_MAJOR_VERSION=16
NPM_MAJOR_VERSION=6
IONIC_CLI_MAJOR_VERSION=6
IONIC_CLI_MINOR_VERSION=16
JAVA_MIN_MAJOR_VERSION=11
JAVA_MIN_MINOR_VERSION=0

# build and run related
EXIT_COMMAND_ERROR_CODE=200
EXIT_NO_DEVICE_CONNECTED_ERROR_CODE=201
EXIT_ERROR_CODE=202
EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE=203
EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE=204
EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE=205
EXIT_NPM_INSTALL_COMMAND_ERROR_CODE=206
EXIT_IONIC_BUILD_COMMAND_ERROR_CODE=207
EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE=208
EXIT_UNIMO_INSTALL_BUILD_ERROR_CODE=209
EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD=210
EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE=211
EXIT_CORDOVA_RES_COMMAND_ERROR_CODE=212
EXIT_IONIC_CAP_RUN_COMMAND_ERROR_CODE=213
EXIT_WRONG_PARAMS_ERROR_CODE=214
EXIT_PROJ_REBUILD_ERROR_CODE=215
EXIT_PRE_REQ_CHECK_FAILURE_CODE=216
EXIT_IONIC_REINSTALL_CAP_IOS_PLATFORM=217
EXIT_CORDOVA_RES_ICON_CUSTOMIZE_ERROR_CODE=218
EXIT_OPEN_IOS_PROJECT_IN_XCODE_ERROR_CODE=219
EXIT_SYNC_CAP_IOS_PROJECT_ERROR_CODE=220
EXIT_IONIC_CAP_PROJ_SYNC_COMMAND_ERROR_CODE=221
EXIT_PSN_TEST_FILE_COPY_ERROR_CODE=222
EXIT_DIR_DELETE_COMMAND_ERROR_CODE=223
EXIT_APB_FCM_JSON_FILE_COPY_ERROR_CODE=234
EXIT_SYNC_CAP_PROJECT_ERROR_CODE=235
EXIT_DIR_DELETE_COMMAND_ERROR_CODE=236
EXIT_IONIC_CAP_IOS_PROJ_SYNC_COMMAND_ERROR_CODE=237

# arguments and globals init
APPBRAHMA_CERT_DEPLOYMENT=1
THIRD_PARTY_CERT_DEPLOYED=2
INVALID_CERT_ISSUER_SELECTION=3
cap_ios_platform_reinstall=0
target=""

# arguments and globals init
build_rebuild=$1
server_rest_api_mode=$2
expected_arg_count=2
build_type_all=0
build_type_ios_platform_reinstall=1
build_type_redo_deps_build_for_cap_platform=2
unimo_build_type=$build_type_all
third_party_cert=0
BUILD="build"
REBUILD="rebuild"
HTTP="http"
HTTPS="https"
CAP_CLI_ERROR='Error while getting Capacitor CLI version'
PLATFORM_ALREADY_INSTALLED='ios platform is already installed'

# function to delete ios platform folders
remove_ios_platform() {
	return_code=0
	remove_ios_platform_and_www_dirs=$(rm -rf ios www 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing iOS and www directories for fixing capacitor incompatibilities for iOS platform!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
		echo "$remove_ios_platform_and_www_dirs"
		return_code=$EXIT_DIR_DELETE_COMMAND_ERROR_CODE
		return
  fi
}
# function common pre-reqs check
unimo_common_pre_reqs_validation() {
	return_code=0
	# OS version validation	
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Your MacOS version is : $(/usr/bin/sw_vers -productVersion)"
	# Minimum version required is Big Sur - 11.0.1 due to Xcode 12+ requirement for ionic capacitor
	if [[ $(/usr/bin/sw_vers -productVersion | awk -F. '{ print $1 }') -ge $OS_MAJOR_VERSION ]]; then
		if [[ $(/usr/bin/sw_vers -productVersion | awk -F. '{ print $2 }') -ge $OS_MINOR_VERSION ]]; then
			if [[ $(/usr/bin/sw_vers -productVersion | awk -F. '{ print $3 }') -ge $OS_PATCH_VERSION ]]; then
				echo "$MOBILE_GENERATOR_LINE_PREFIX : MacOS version requirement - $OS_MAJOR_VERSION.$OS_MINOR_VERSION.$OS_PATCH_VERSION - met, moving ahead with other checks..."
			else
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running un-supported MacOS version $(/usr/bin/sw_vers -productVersion) for building and running AppBrahma generated Unimobile application project sources!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $OS_MAJOR_VERSION.$OS_MINOR_VERSION.$OS_PATCH_VERSION${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please retry after ensuring pre-requisites are met.${NT}"
				return_code=$EXIT_MACOS_VERSION_CHECK_COMMAND_ERROR_CODE
				return
			fi
		else
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running un-supported MacOS version $(/usr/bin/sw_vers -productVersion) for building and running AppBrahma generated Unimobile application project sources!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $OS_MAJOR_VERSION.$OS_MINOR_VERSION.$OS_PATCH_VERSION${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please retry after ensuring pre-requisites are met.${NT}"
			return_code=$EXIT_MACOS_VERSION_CHECK_COMMAND_ERROR_CODE
			return
		fi
	else
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running unsupported MacOS version $(/usr/bin/sw_vers -productVersion) for building and running AppBrahma generated Unimobile application project sources!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $OS_MAJOR_VERSION.$OS_MINOR_VERSION.$OS_PATCH_VERSION${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please retry after ensuring pre-requisites are met.${NT}"
		return_code=$EXIT_MACOS_VERSION_CHECK_COMMAND_ERROR_CODE
		return
	fi

	# Xcode version validation
	if [[ $(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}' | awk -F. '{print $1}') -ge XCODE_MAJOR_VERSION ]]; then
		if [[ $(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}' | awk -F. '{print $2}') -ge XCODE_MINOR_VERSION ]]; then
			if [[ $(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}' | awk -F. '{print $3}') -ge XCODE_PATCH_VERSION ]]; then
				echo "$MOBILE_GENERATOR_LINE_PREFIX : Xcode version requirement - $XCODE_MAJOR_VERSION.$XCODE_MINOR_VERSION.$XCODE_PATCH_VERSION - met, moving ahead with other checks..."
			else
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported Xcode version $(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}')!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $XCODE_MAJOR_VERSION.$XCODE_MINOR_VERSION.$XCODE_PATCH_VERSION${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process!${NT}"            
				exit $EXIT_XCODE_VERSION_CHECK_COMMAND_ERROR_CODE
			fi
		else
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported Xcode version $(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}')!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $XCODE_MAJOR_VERSION.$XCODE_MINOR_VERSION.$XCODE_PATCH_VERSION${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process!${NT}"        
			exit $EXIT_XCODE_VERSION_CHECK_COMMAND_ERROR_CODE
		fi
	else
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported Xcode version $(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}')!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $XCODE_MAJOR_VERSION.$XCODE_MINOR_VERSION.$XCODE_PATCH_VERSION${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process!${NT}"    
		exit $EXIT_XCODE_VERSION_CHECK_COMMAND_ERROR_CODE
	fi

	# xcode-select command tools verification
	if [[ $(xcode-select --version | awk '{ print $3 }') < $XCODE_SELECT_MIN_VERSION ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported xcode-select version $(xcode-select --version | awk '{ print $3 }' | awk -F. '{ print $1 }')!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $XCODE_SELECT_MIN_VERSION+${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process!${NT}"    
		exit $EXIT_XCODE_SELECT_VERSION_CHECK_COMMAND_ERROR_CODE
	else
		echo "$MOBILE_GENERATOR_LINE_PREFIX : xcode-select version requirement - $XCODE_SELECT_MIN_VERSION - met, moving ahead with other checks..."
	fi

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
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $NODE_MAJOR_VERSION+${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS NodeJS version of major release $NODE_MAJOR_VERSION+ and retry running this script.${NT}"    
		return_code=$EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE
		return 
	else
	    	echo "$MOBILE_GENERATOR_LINE_PREFIX : Nodejs major version requirement - $NODE_MAJOR_VERSION - met. Moving ahead with other checks..."
	fi

	# npm install check
	npm_command=$(npm --version 2>&1)
	if [ $? -gt 0 ]; then
		    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : npm (Node Package Manager) is not installed or NOT in PATH!${NT}"
		    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS version of npm major release $NPM_MAJOR_VERSION+ and retry running this script.${NT}"    
		    return_code=$EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE
		    return 
	fi

	# npm version check
	npm_version=$(npm --version | awk -F. '{ print $1 }' 2>&1)
	if [ $npm_version -lt $NPM_MAJOR_VERSION ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported NPM major version $(npm --version | awk -F. '{ print $1 }')!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required major NPM version is $NPM_MAJOR_VERSION+${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS NPM version of major release $NPM_MAJOR_VERSION+ and retry running this script.${NT}"
		return_code=$EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE
		return
	else
	    	echo "$MOBILE_GENERATOR_LINE_PREFIX : NPM major version requirement - $NPM_MAJOR_VERSION - met, moving ahead with other checks..."
	fi

	# cocoapods install check
	cocoapods_command=$(pod --version 2>&1)
	if [ $? -gt 0 ]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Cocoapods is not installed!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install cocoapods and retry running this script.${NT}"    
		exit $EXIT_COCOAPADS_VERSION_CHECK_COMMAND_ERROR_CODE
	fi

	# cocoapods version check
	if [[ $(pod --version | awk -F. '{ print $1 }') -lt $COCOAPODS_MAJOR_VERSION ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Cocoapods is not installed or a non-supported version $(pod --version | awk -F. '{ print $1 }')!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required version is $COCOAPODS_MAJOR_VERSION+${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process!${NT}"    
		exit $EXIT_COCOAPADS_VERSION_CHECK_COMMAND_ERROR_CODE
	else
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Cocoapods version requirement - $COCOAPODS_MAJOR_VERSION - met, moving ahead with other checks..."
	fi

	# ionic install check
	ionic_command=$(ionic --version 2>&1)
	if [ $? -gt 0 ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Ionic CLI is not installed or not in PATH!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please install a stable and LTS version of Ionic CLI version $IONIC_CLI_MAJOR_VERSION.$IONIC_CLI_MINOR_VERSION or greater and retry running this script.${NT}"    
	    return_code=$EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	fi

	# ionic cli version validation
	ionic_cli_version=$(ionic --version | awk -F. '{ print $1 }')
	if [ $ionic_cli_version -lt $IONIC_CLI_MAJOR_VERSION ]; then
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You are running non-supported Ionic CLI major version $ionic_cli_version!${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Minimum required Ionic CLI version is $IONIC_CLI_MAJOR_VERSION.$IONIC_CLI_MINOR_VERSION+${NT}"
	    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the build process. Please install a stable and LTS Ionic CLI version of major release $IONIC_CLI_MAJOR_VERSION.$IONIC_CLI_MINOR_VERSION+ and retry running this script.${NT}"
	    return_code=$EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE
	    return
	else
	    echo "$MOBILE_GENERATOR_LINE_PREFIX : Ionic CLI major version requirement - $IONIC_CLI_MAJOR_VERSION.$IONIC_CLI_MINOR_VERSION - met, moving ahead with other checks..."
	fi	
	echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Pre-requisites validation completed successfully.${NT}"
}

# function to re-install node deps
npm_reinstall() {
	return_code=0
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Now re-installing nodejs dependencies..."
	NPM_INSTALL_DEPS_COMMAND_RES=$(npm install --force 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Re-attempt to install nodejs dependencies resulted in error!${NT}"
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
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing node_modules for fixing dependencies install errors!${NT}"            
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
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error building project!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"		
		echo "$ionic_build_command_res"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
		return_code=$EXIT_IONIC_BUILD_COMMAND_ERROR_CODE
		return
	fi    	
}

# function to add capacitor ios platform
add_cap_platform() {
	return_code=0
	ADD_CAPACITOR_PLATFORM_COMMAND_RES=$(ionic cap add ios 2>&1)
	if [[ $? -ne 0 ]]; then
		echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Found issues in adding iOS platform!${NT}"
		echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Diagnosing for the root cause...${NT}"						

		case $ADD_CAPACITOR_PLATFORM_COMMAND_RES in 		
		# check for any capacitor cli version in-compatibility error. If so, delete node_modules and run a fresh build using the same script								
		*"$CAP_CLI_ERROR"*)	    		
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Capacitor version incompatibilities found. Fixing the incompatibilities..."
			remove_capacitor_platform_and_node_deps_res=$(rm -rf ios node_modules www 2>&1)
			if [[ $? -ne 0 ]]; then
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing node_modules, ios, and www directories for fixing capacitor incompatibilities for ios platform!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
				echo "$remove_capacitor_platform_and_node_deps_res"
				return_code=$EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE
				return
			else				
				unimo_build_type=$build_type_redo_deps_build_for_cap_platform
				return_code=$EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD
				return
			fi			
		;;
		# if the ios platform was already installed, sync it
		*"$PLATFORM_ALREADY_INSTALLED"*)
			echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : iOS platform was already added!${NT}"
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronizing capacitor iOS platform..."			
			synchronize_cap_ios_res=$(ionic cap sync ios 2>&1)
			if [[ $? -ne 0 ]]; then
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error synchronizing iOS platform!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
				echo "$synchronize_cap_ios_res"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"				
				return_code=$EXIT_IONIC_CAP_PROJ_SYNC_COMMAND_ERROR_CODE				
				return
			else			
				echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Synchronized capacitor iOS platform.${NT}"
				return_code=0
				return
			fi
		;;
		esac
	else
		echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Added capacitor iOS platform.${NT}"
		return_code=0
		return
	fi
}

# function to build unimo app
unimo_install_ionic_deps_build_and_platform() {	
	# check the type of action to take for it could have been a nested call
	if [[ $unimo_build_type -eq $build_type_ios_platform_reinstall ]]; then
		# any special handling for re-adding cap ios platform
		echo "$MOBILE_GENERATOR_LINE_PREFIX : Now re-adding capacitor iOS platform..."
		add_cap_platform
		if [[ $return_code -ne 0 ]]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error re-adding capacitor iOS platform!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting Unimobile build and run process.${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing above reported errors.${NT}"
			return_code=$EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE
			return
		else
			# sync it after adding the platform
			echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronizing capacitor iOS platform..."
			synchronize_cap_ios_res=$(ionic cap sync ios 2>&1)
			if [[ $? -ne 0 ]]; then
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error synchronizing iOS platform!${NT}"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
				echo "$synchronize_cap_ios_res"
				echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
				return_code=$EXIT_IONIC_CAP_PROJ_SYNC_COMMAND_ERROR_CODE
				return
			else
				# echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronized capacitor iOS platform."
				return_code=0
				return
			fi
		fi

	fi

	if [[ $unimo_build_type -eq $build_type_redo_deps_build_for_cap_platform ]]; then
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

	echo "$MOBILE_GENERATOR_LINE_PREFIX : Now adding capacitor iOS platform..."
	add_cap_platform
	case $return_code in 
		$EXIT_IONIC_REINSTALL_CAP_IOS_PLATFORM)
			unimo_build_type=$build_type_ios_platform_reinstall
			unimo_install_ionic_deps_build_and_platform
			if [[ $return_code -ne 0 ]]; then
				# any needed error handling
				return
			fi
			return
		;;

		$EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD)
			unimo_build_type=$build_type_redo_deps_build_for_cap_platform
			unimo_install_ionic_deps_build_and_platform
			if [[ $return_code -ne 0 ]]; then
				# any needed error handling
				return
			fi
			return
		;;

		0)
			# echo "$MOBILE_GENERATOR_LINE_PREFIX : Installed capacitor iOS platform."
			return_code=0
			return
		;;

		*)
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error adding capacitor iOS platform!${NT}"
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Please fix these issues and re-run this script.${NT}"			
			return_code=$EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE
			return
		;;
	esac
}

resync_ios_platform_after_fcm_files() {  
  delete_dir=$(rm -rf ios www 2>&1)
  if [ $? -gt 0 ]; then
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing iOS and www directories for re-building the project!${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting the execution.${NT}"
    echo "$delete_dir"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
    $return_code=$EXIT_PROJ_REBUILD_ERROR_CODE
    return
  else
    echo "$MOBILE_GENERATOR_LINE_PREFIX : Removed iOS and www directories for re-building the project."
    read -p "$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue..."
  fi

  # call ionic build with deps
  unimo_build_type=$build_type_redo_deps_build_for_cap_platform
  unimo_install_ionic_deps_build_and_platform
  if [[ $return_code -ne 0 ]]; then
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error re-building Unimobile project and adding iOS platform!${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
	$return_code=$EXIT_SYNC_CAP_IOS_PROJECT_ERROR_CODE
    return
  fi

  echo "$MOBILE_GENERATOR_LINE_PREFIX : Re-customising Unimobile application icon and splash images..."
  customize_app_icons_res=$(cordova-res ios --skip-config --copy 2>&1)
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
	echo "${ERROR}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : In-sufficient or invalid arguments supplied - needed $expected_arg_count but "$#" supplied!${NT}"
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
	if [ -d "ios" ]; then
		delete_dir=$(rm -rf "ios" 2>&1)
		if [ $? -gt 0 ]; then
			echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing iOS directory for rebuilding!${NT}"
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
# prompt user to copy google-services.json file for FCM push notifications to under capacitor iOS project directory - ios\App\App in ionic project root
echo "${YELLOW}$MOBILE_GENERATOR_LINE_PREFIX : This Unimobile app is generated with out-of-the-box push notifications implementation using Firebase Cloud Messaging by AppBrahma MVP Generator Service.${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : There are a couple of pre-requisites that needs to be performed for building and running the app successfully with push notifications support.${NT}"
echo "	1.Set-up ${GREEN}${BOLD}App ID (Identifiers -> Identifiers+) and create APN Key (Keys -> Keys+)${NT} on Apple Developer Portal and download APN Key (.p8) file. Apple developer account is a paid subscription account."
echo "	2.Set-up ${GREEN}${BOLD}Firebase Cloud Messaging for push notification in firebase console${NT} for this ios app, upload above generated APN Key file (.p8), and download GoogleService-Info.plist file - https://console.firebase.google.com"
echo "	3.Copy this .plist file to <unimobile_project_root>\ios\App\App."
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please be aware that the Unimobile mobile application will crash at the start up, if you do not perform the above steps!${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Alternatively, for quick app testing, you can use AppBrahma generated sample FCM GoogleService-Info.plist and change the appID temporarily to sample appID.${NT}"

# prompt user for selection
use_configured_info="Use already configured FCM push notification info"
psj_selection=('Yes' 'No - I will set up FCM and download GoogleService-Info.plist file' "$use_configured_info")
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
	remove_ios_platform
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing iOS platform for updating the project!${NT}"
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"		
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
		exit $EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE
	fi
  ;;
  # user chose to generate FCM files and configure himself
  *"No"*)    
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue after downloading the GoogleService-Info.plist file...${NT}"
    echo "$MOBILE_GENERATOR_LINE_PREFIX : You will be prompted to copy this file to <unimobile_project_root>/ios/App/App/ folder after building ionic project."
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue...${NT}"
	remove_ios_platform
	if [[ $? -ne 0 ]]; then
		echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error removing iOS platform for updating the project!${NT}"
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
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error in building the project and installing iOS platform!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed above. Aborting the execution.${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running this script after fixing the displayed errors.${NT}"
	exit $return_code
fi

# FCM GoogleService-Info.plist file copy
case $psj_user_selection in
  # user chose to use AppBrahma generated sample appID FCM files and info
  *"Yes"*)
    echo "$MOBILE_GENERATOR_LINE_PREFIX : Copying AppBrahma generated GoogleService-Info.plist from <unimobile_project_root>/unimobile/samples/push-notifications/ios folder to <unimobile_project_root>/ios/App/App/..."
    copy_fcm_pn_json=$(cp -f "unimobile/samples/push-notifications/ios/GoogleService-Info.plist" "ios/App/App/" 2>&1)
    if [ $? -ne 0 ]; then
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error copying AppBrahma generated sample GoogleService-Info.plist file. Error details are displayed below. Aborting the execution.${NT}"
      echo "$copy_fcm_pn_json"
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Fix the above errors and retry running this script.${NT}"
      exit $EXIT_APB_FCM_JSON_FILE_COPY_ERROR_CODE
    fi
    echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : AppBrahma generated sample GoogleService-Info.plist copied successfully.${NT}"

	echo "$MOBILE_GENERATOR_LINE_PREFIX : Copying unimo-push-notification-test.apns from the <unimobile_project_root>\unimobile\samples\push-notifications\ios folder to unimobile project root folder <unimobile_project_root>..."	
    copy_psn_test_file=$(cp -f "unimobile/samples/push-notifications/ios/unimo-push-notification-test.apns" "." 2>&1)
    if [ $? -ne 0 ]; then
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error copying AppBrahma generated unimo-push-notification-test.apns file which is used fo push notification testing. Error details are displayed below. Aborting the execution.${NT}"
      echo "$copy_psn_test_file"
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Fix the above errors and retry running this script.${NT}"
      exit $EXIT_PSN_TEST_FILE_COPY_ERROR_CODE
    fi
    echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : AppBrahma generated sample unimo-push-notification-test.apns copied successfully.${NT}"
  ;;
  # user chose to generate FCM files and configure himself
  *"No"*)
    echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : As you chose to generate FCM files yourself for this Unimobile app, please complete the step of copying the downloaded GoogleService-Info.plist file to <unimobile_project_root>/ios/App/App/ now.${NT}"
    echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please be aware that the Unimobile mobile application will crash at the start up, if you do not perform the above step!${NT}"
    read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue after completing the above step...${NT}"
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Copying unimo-push-notification-test.apns from the <unimobile_project_root>\unimobile\samples\push-notifications\ios folder to unimobile project root folder <unimobile_project_root>..."	
    copy_psn_test_file=$(cp -f "unimobile/samples/push-notifications/ios/unimo-push-notification-test.apns" "." 2>&1)
    if [ $? -ne 0 ]; then
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error copying AppBrahma generated unimo-push-notification-test.apns file which is used fo push notification testing. Error details are displayed below. Aborting the execution.${NT}"
      echo "$copy_psn_test_file"
      echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Fix the above errors and retry running this script.${NT}"
      exit $EXIT_PSN_TEST_FILE_COPY_ERROR_CODE
    fi
    echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : AppBrahma generated sample unimo-push-notification-test.apns copied successfully.${NT}"
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
customize_app_icons_res=$(cordova-res ios --skip-config --copy 2>&1)
if [[ $? -ne 0 ]]; then
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error customising the application icon and splash images!${NT}"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error details are:${NT}"
	echo "$customize_app_icons_res"
	echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Aborting the execution. Please retry running this script after fixing the above reported issues.${NT}"
	exit $EXIT_CORDOVA_RES_ICON_CUSTOMIZE_ERROR_CODE
fi
echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Customised Unimobile application icon and splash images.${NT}"

# https check for prep-up
if [[ "$server_rest_api_mode" == "https" ]]; then			
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : You have chosen https for back-end server protocol. For https support by iOS apps, a signed server certificate needs to be deployed onto back-end server."		
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please ensure back-end server is deployed with a publicly known CA signed server certificate or a self-signed server certificate."	
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : If you are deploying self-signed (with or without CA) certificate, please ensure you've deployed the back-end server's self-signed certificate onto the device you are targeting."	
	echo "$MOBILE_GENERATOR_LINE_PREFIX : Apple link for steps on certificate deployment onto iOS devices is: https://support.apple.com/en-in/guide/deployment/depcdc9a6a3f/web"		
	echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Please be aware that a self-signed or non-public CA signed back-end server certificate may require special certificate store/trust configurations on iOS and Android devices for enabling HTTPS access to this server from Apps running on these devices - especially Unimobile app you might have generated for this server by AppBrahma MVP generator.${NT}"			
	read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue, after completing the above steps...${NT}"			
fi

echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : There are a couple more things that needs to be performed in Xcode Unimobile project for building and running the project succesfully on the target.${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Up next, Unimobile iOS project will be opened in Xcode for configuring Push Notification capability and team.${NT}"
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : After Xcode opens with Unimobile iOS project,${NT}"
echo "	1.Add/select Team - ${YELLOW}${BOLD}Xcode -> App -> Signing & Capabilities -> Team${NT}"
echo "	2.Add Push Notification Capability - ${YELLOW}${BOLD}Xcode -> App -> Signing & Capabilities -> + Capability -> Push Notifications${NT}"
echo "	3.Add GoogleService-Info.plist to unimobile app project in ${YELLOW}${BOLD}Xcode - App -> App -> Right Click -> Add Files to App -> Select this .plist file${NT}"
echo "	4.Select a target to build and run this project in Xcode - the top middle bar in Xcode"
read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue, when ready...${NT}"			

echo "$MOBILE_GENERATOR_LINE_PREFIX : Synchronizing iOS platform..."
synchronize_cap_ios_res=$(ionic cap sync ios 2>&1)
if [[ $? -ne 0 ]]; then
	echo "${RED}$MOBILE_GENERATOR_LINE_PREFIX : Error synchronizing iOS platform!${NT}"
	echo "${RED}$MOBILE_GENERATOR_LINE_PREFIX : Error details are displayed below. Aborting Unimobile build and run process.${NT}"
	echo "$synchronize_cap_ios_res"
	echo "${RED}$MOBILE_GENERATOR_LINE_PREFIX : Please retry running the script after fixing these reported errors.${NT}"
	return_code=$EXIT_IONIC_CAP_IOS_PROJ_SYNC_COMMAND_ERROR_CODE
	return
else
	echo "${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Synchronized capacitor iOS platform.${NT}"
fi

echo "$MOBILE_GENERATOR_LINE_PREFIX : Additionally, you can test push notification for the unimobile app running on simulator by using the below command, while a single simulator, with your app deployed, is running - using the AppBrahma generated APNS test file."
echo "	Command : xcrun simctl push booted \<bundle_or_app_id\> \<apns_json_file\>.apns"
echo "	Example : ${GREEN}${BOLD}xcrun simctl push booted com.brillium.unimobile.pn.demo unimo-push-notification-test.apns${NT} - on terminal from unimobile project root<unimobile_project_root> folder after running the app on the target for testing the push notifications."
read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key to continue, when ready...${NT}"			

# display credentials for log in - for server integrated template
echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : After the Unimobile app opens on the target you have selected:${NT}"
echo "	1.Run the backend server in a seperate console using AppBrahma build and run script, if it is AppBrahma generated back-end server."
echo "	2.Use the below user credentials to log in from Unimobile app to the back-end server"
echo ${YELLOW}		- Admin user - Username: brahma, Password: brahma@appbrahma${NT}
echo ${YELLOW}		- End user - Username: manasputhra, Password: manasputhra@appbrahma${NT}
echo ""
# acknowledgement and best wishes
echo "${BOLD}${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Wishing you best for faster quality development sprint cycles and go-live.${NT}"
echo "${GREEN}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Powered and brought to you by the passion, perseverance, and pursuit of efficiency by Brillium Technologies to transform the world through technology.${NT}"
echo "${BOLD}${GREEN}$MOBILE_GENERATOR_LINE_PREFIX : Thank you for giving us the opportunity to serve you in going live quickly with your MVP by cutting down your development time and effort of the first runnable version of your full-stack product from months of team work to a few individual clicks.${NT}"
echo "${BOLD}${GREEN}-Team AppBrahma${NT}"
read -p "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Press any key when ready to open Xcode, build, and run your unimobile app on the selected target...${NT}"

open_unimobile_in_xcode_res=$(ionic cap open ios 2>&1)
if [[ $? -ne 0 ]]; then
    echo "${RED}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Error opening iOS project in Xcode. Aborting appbrahma build and run script!${NT}"
    echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : Try the below:{$NT}"
	echo "	1.Execute - ${GREEN}${BOLD}ionic cap open ios${NT} - on terminal from unimobile project root folder <unimobile_project_root>"
	echo "	2.Select a target to build and run this project in Xcode - the top middle bar in Xcode"
	echo "	3.Execute - ${GREEN}${BOLD}xcrun simctl push booted com.brillium.unimobile.pn.demo unimo-push-notification-test.apns${NT} - on terminal from unimobile project root<unimobile_project_root> folder after running the app on the target for testing the push notifications."
	echo ""
fi
echo "${YELLOW}${BOLD}$MOBILE_GENERATOR_LINE_PREFIX : In case of issues in opening the project folder by Xcode, please execute the below command on the console:${NT}"
echo "	${GREEN}${BOLD}ionic cap open ios${NT}"
