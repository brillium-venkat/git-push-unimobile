:: =======================================================================================================================
:: UniBrahma script for building and running Unimobile app on a target from Windows
:: Author :Venkateswar Reddy Melachervu
:: History:
::	16-12-2021 - Creation
::  17-12-2021 - Added gracious error handling and recovery mechansim for already added android platform
::  26-12-2021 - Added error handling and android sdk path check
::  20-01-2022 - Created script for linux
::  29-01-2022 - Updated
::  27-02-2022 - Updated for streamlining exit error codes and re-organizing build code into a function for handling 
::               dependency version incompatibilities
::	07-03-2022 - Updated for function exit codes, format and app display prefix
::	08-03-2022 - Updated for pre-req version validations
::	12-03-2022 - Updated for installation checks and de-cluttering the console output by capturing the output into env variable
::	23-03-2022 - HTTPS self signed cert deployment and api level support
::  24-03-2022 - Merging both batch files for http and https
::  27-03-2022 - Unified http and https script files into one 
:: 			   - Reference article - https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/
::	22-03-2022 - Included support for android sdk api levels below 28 and above 28#      
::  27-03-2022 - Unified http and https script files into one
::  05-06-2022 - Modifications for push notifications and android device connection
::  15-06-2022 - Unifying with Linux and MacOS scripts and update for connected AVDs/sdevices
::	17-06-2022 - Added dir delete error handling
::	07-07-2022 - Colored font and unification of styles with server-side script
::
:: (C) Brillium Technologies 2011-2022. All rights reserved.	
:: =======================================================================================================================

@echo off
Setlocal EnableDelayedExpansion
set "NT=[0m"
set "BOLD=[1m"
set "UL=[4m"
set "NRED=[31m"
set "NGREEN=[32m"
set "NYELLOW=[33m"
set "NWHITE=[37m"
set "SRED=[91m"
set "SGREEN=[92m"
set "SYELLOW=[93m"
set "SBLUE=[94m"
set "SMAGENTA=[95m"
set "SCYAN=[96m"
set "SWHITE=[97m"

set "ERROR=%SRED%"
set "WARNING=%SYELLOW%"
set "ATTENTION=%SWHITE%"
set "SUCCESS=%SGREEN%"
set "INFO=%WHITE%"
set "ACCENT=%SCYAN%"

set "UNIMO_APP_NAME=Git Push Unimobile"
set "MOBILE_GENERATOR_NAME=AppBrahma"
set "TERM_TITLE=%MOBILE_GENERATOR_NAME%"
set "MOBILE_GENERATOR_LINE_PREFIX=[%MOBILE_GENERATOR_NAME%]"
set "CERT_DEPLOYER_LINE_PREFIX=[%CERT_DEPLOYER%]"
set "NODE_MAJOR_VERSION=16"
set "NPM_MAJOR_VERSION=6"
set "IONIC_CLI_MAJOR_VERSION=6"
set "IONIC_CLI_MINOR_VERSION=16"
set "JAVA_MIN_VERSION=11"
set "JAVA_MIN_MAJOR_VERSION=11"
set "JAVA_MIN_MINOR_VERSION=0"

:: cert deployment related
set "EXIT_CERT_DEPLOYER_EXIT_CODE_BASE=150"
set "EXIT_ADB_EMULATOR_PATHS_ERROR=151"
set "EXIT_COMMAND_ERROR_CODE=152"
set "EXIT_ANDROID_HOME_PATH_COMMAND_ERROR_CODE=153"
set "EXIT_ADB_DEV_LIST_COMMAND_ERROR_CODE=154"
set "EXIT_EMULATOR_HELP_COMMAND_ERROR_CODE=155"
set "EXIT_ADB_HELP_COMMAND_ERROR_CODE=156"
set "EXIT_EMULATOR_LIST_AVDS_HELP_COMMAND_ERROR_CODE=157"
set "EXIT_ADB_LIST_DEVICES_HELP_COMMAND_ERROR_CODE=158"
set "EXIT_NO_DEVICE_CONNECTED_ERROR_CODE=159"
set "EXIT_OPENSSL_NOT_IN_PATH_ERROR_CODE=160"
set "EXIT_CERT_HASH_GEN_COMMAND_ERROR_CODE=161"
set "EXIT_RUN_EMULATOR_COMMAND_ERROR_CODE=162"
set "EXIT_RESTART_ADB_AS_ROOT_COMMAND_ERROR_CODE=163"
set "EXIT_DISABLE_SECURE_ROOT_COMMAND_ERROR_CODE=164"
set "EXIT_ADB_REBOOT_COMMAND_ERROR_CODE=165"
set "EXIT_REMOUNT_PARTITIONS_COMMAND_ERROR_CODE=166"
set "EXIT_PUSH_SIGNED_CERT_COMMAND_ERROR_CODE=167"
set "EXIT_SET_CERT_PERMS_COMMAND_ERROR_CODE=168"
set "EXIT_ADB_DEVICES_COMMAND_ERROR_CODE=169"

:: build and run related
set "EXIT_ERROR_CODE=200"
set "EXIT_WINDOWS_VERSION_CHECK_COMMAND_ERROR_CODE=201"
set "EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE=202"
set "EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE=203"
set "EXIT_IONIC_CLI_VERSION_CHECK_COMMAND_ERROR_CODE=204"
set "EXIT_JAVA_VERSION_CHECK_COMMAND_ERROR_CODE=205"
set "EXIT_JDK_VERSION_CHECK_COMMAND_ERROR_CODE=206"
set "EXIT_EMULATOR_HELP_COMMAND_ERROR_CODE=207"
set "EXIT_NPM_INSTALL_COMMAND_ERROR_CODE=208"
set "EXIT_IONIC_BUILD_COMMAND_ERROR_CODE=209"
set "EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE=210"
set "EXIT_UNIMO_INSTALL_BUILD_ERROR_CODE=211"
set "EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD=212"
set "EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE=213"
set "EXIT_CORDOVA_RES_COMMAND_ERROR_CODE=214"
set "EXIT_ADB_VERSION_COMMAND_ERROR_CODE=215"
set "EXIT_IONIC_CAP_RUN_COMMAND_ERROR_CODE=216"
set "EXIT_GET_SDK_API_LEVEL_ERROR_CODE=217"
set "EXIT_ADB_REVERSE_COMMAND_ERROR_CODE=218"
set "EXIT_WRONG_PARAMS_ERROR_CODE=219"
set "EXIT_EMULATOR_LIST_AVDS_COMMAND_ERROR_CODE=220"
set "EXIT_PROJ_REBUILD_ERROR_CODE=221"
set "EXIT_PRE_REQ_CHECK_FAILURE_CODE=222"
set "EXIT_CERT_DEPLOYMENT_PRE_REQ_CHECK_FAILURE_CODE=223"
set "EXIT_CERT_DEPLOYMENT_FAILURE_CODE=224"
set "EXIT_ANDROID_HOME_NOT_SET_CODE=225"
set "EXIT_EMULATOR_EXE_PATH_NOT_PROPERLY_SET_CODE=226"
set "EXIT_ANDROID_PLATFORM_TOOLS_NOT_IN_PATH_CODE=227"
set "EXIT_ANDROID_SDK_TOOLS_NOT_SET_IN_PATH_CODE=228"
set "EXIT_ANDROID_SDK_PATH_NOT_SET_IN_PATH_CODE=229"
set "EXIT_IONIC_REINSTALL_CAP_ANDROID_PLATFORM=230"
set "EXIT_CORDOVA_RES_ICON_CUSTOMIZE_ERROR_CODE=231"
set "EXIT_IONIC_CAP_ANDROID_RUN_COMMAND_ERROR_CODE=232"
set "EXIT_ADB_REVERSE_TCP_COMMAND_ERROR_CODE=233"
set "EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE=234"
set "EXIT_DIR_DELETE_COMMAND_ERROR_CODE=235"
set "EXIT_APB_FCM_JSON_FILE_COPY_ERROR_CODE=236"
set "EXIT_ANDROID_PLATFORM_REMOVE_ERROR_CODE=237"


set "output_tmp_file=.unibrahma-build-n-run.tmp"
set "child1_output_tmp_file=.unibrahma-build-n-run-child-1.tmp"
set "emu_menu_opts=.unibrahma-build-n-run-emu-menu-opts.tmp"
set "output_tmp_2_file=.unibrahma-build-n-run-2.tmp"
set "hash_named_cert="

set /A "APPBRAHMA_CERT_DEPLOYMENT=1"
set /A "THIRD_PARTY_CERT_DEPLOYED=2"
set /A "INVALID_CERT_ISSUER_SELECTION=3"
set /A cap_android_platform_reinstall=0
set "target="

:: arguments and globs
set "build_rebuild=%1"
set "server_rest_api_mode=%2"
set "expected_arg_count=2"
set /A build_type_all=0
set /A "build_type_android_platform_reinstall=1"
set /A "build_type_redo_deps_build_cap_android_platform=2"
set "unimo_build_type=!build_type_all!"
set /A "third_party_cert=0"
set /A "arg_count=0"
set "BUILD=build"
set "REBUILD=rebuild"
set "HTTP=http"
set "HTTPS=https"
set "PLATFORM_ALREADY_INSTALLED=android platform is already installed"
set "CAP_CLI_ERROR=Error while getting Capacitor CLI version"
set "ACCESS_DENIED=Access is denied"
set "BEING_USED_BY_OTHER_PROCESS=being used by another process"

title "%MOBILE_GENERATOR_NAME% - !UNIMO_APP_NAME! - Build and Run"
cls
echo ===================================================================================================================================================
echo 		Welcome to %SGREEN%%BOLD%%UNIMO_APP_NAME% build and run script generated by %SGREEN%%MOBILE_GENERATOR_NAME% - the baap of apps%NT%"
echo Sit back, relax, and sip a cup of coffee while the dependencies are downloaded, project is built, and run.
echo %NYELLOW%Unless the execution of this script stops, do not be bothered nor worried about any warnings or errors displayed during the execution.%NT%
echo -Team AppBrahma
echo ===================================================================================================================================================
echo %SYELLOW%%MOBILE_GENERATOR_NAME% : You typed - "%~nx0 %*%NT%"
echo.
:: arguments
:: %1 - build/rebuild - rebuild cleans the target directory, node_modules etc. forcibly
:: %2 - http/https - Unimobile app server protocol support - http or https

:: args count
for %%g in (%*) do (
	set /A arg_count+=1
)
:: args count validation
if !arg_count! LSS !expected_arg_count! ( 
	echo %ERROR%%MOBILE_GENERATOR_LINE_PREFIX% : In-sufficient arguments supplied - needed !expected_arg_count! but !arg_count! supplied^^!%NT%		
	echo %BOLD%Usage:%NT%
	echo 	$0 %BOLD%^<build_task_type^> ^<server_protocol^>%NT%
	echo %BOLD%Arguments:%NT%
	echo 	%SGREEN%build-task-type%NT%:
	echo 		- Build or rebuild. Rebuild cleans the target forcibly. 
	echo 		- Mandatory argument. Allowed values - %SGREEN%build%NT% or %SGREEN%rebuild%NT%.
	echo 	%SGREEN%server-protocol%NT%:
	echo 		- Backend server protocol. HTTP is NOT auto-redirected to HTTPS.
    echo 		- Mandatory argument. Allowed values - %SGREEN%http%NT% or %SGREEN%https%NT%.	
	exit /b %EXIT_WRONG_PARAMS_ERROR_CODE%		
)
:: args validation
if not !build_rebuild!==!BUILD! (
	if not !build_rebuild!==!REBUILD! (
		echo %ERROR%%MOBILE_GENERATOR_LINE_PREFIX% : Invalid value - "!build_rebuild!" - supplied for the first argument^^!%NT%
		echo %BOLD%Usage:%NT%
		echo 	$0 %BOLD%^<build_task_type^> ^<server_protocol^>%NT%
		echo %BOLD%Arguments:%NT%
		echo 	%SGREEN%build-task-type%NT%:
		echo 		- Build or rebuild. Rebuild cleans the target forcibly. 
		echo 		- Mandatory argument. Allowed values - %SGREEN%build%NT% or %SGREEN%rebuild%NT%.
		echo 	%SGREEN%server-protocol%NT%:
		echo 		- Backend server protocol. HTTP is NOT auto-redirected to HTTPS.
		echo 		- Mandatory argument. Allowed values - %SGREEN%http%NT% or %SGREEN%https%NT%.	
		exit /b %EXIT_WRONG_PARAMS_ERROR_CODE%		
	) 
)
if not !server_rest_api_mode!==!HTTP! (
	if not !server_rest_api_mode!==!HTTPS! (
		echo %ERROR%%MOBILE_GENERATOR_LINE_PREFIX% : Invalid value - "!server_rest_api_mode!" - supplied for the second argument^^!%NT%
		echo %BOLD%Usage:%NT%
		echo 	$0 %BOLD%^<build_task_type^> ^<server_protocol^>%NT%
		echo %BOLD%Arguments:%NT%
		echo 	%SGREEN%build-task-type%NT%:
		echo 		- Build or rebuild. Rebuild cleans the target forcibly. 
		echo 		- Mandatory argument. Allowed values - %SGREEN%build%NT% or %SGREEN%rebuild%NT%.
		echo 	%SGREEN%server-protocol%NT%:
		echo 		- Backend server protocol. HTTP is NOT auto-redirected to HTTPS.
		echo 		- Mandatory argument. Allowed values - %SGREEN%http%NT% or %SGREEN%https%NT%.	
		exit /b %EXIT_WRONG_PARAMS_ERROR_CODE%		
	) 
)

:: remove any residual temp logs
if exist !output_tmp_file! (
	for /F "tokens=*" %%G in ('del /F !output_tmp_file!' ) do (									
		set "del_result=%%G"
	)		
) 
if exist !child1_output_tmp_file! (
	for /F "tokens=*" %%G in ('del /F !child1_output_tmp_file!' ) do (									
		set "del_result=%%G"
	)		
) 
if exist !emu_menu_opts! (
	for /F "tokens=*" %%G in ('del /F !emu_menu_opts!' ) do (									
		set "del_result=%%G"
	)		
) 
if exist !output_tmp_2_file! (
	for /F "tokens=*" %%G in ('del /F !output_tmp_2_file!' ) do (									
		set "del_result=%%G"
	)		
) 


if "!build_rebuild!" == "!REBUILD!" (
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Rebuild is requested. Cleaning the project for the rebuild...
	if exist node_modules\ (
		call rmdir /S /Q "node_modules"  > "!output_tmp_file!" 2>&1			
		if !ERRORLEVEL! NEQ 0  (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting node_modules directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%	
		)
		call findstr /i /n /c:"!BEING_USED_BY_OTHER_PROCESS!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting node_modules directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
		call findstr /i /n /c:"!ACCESS_DENIED!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting node_modules directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%	
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
	)
	if exist android\ (
		call rmdir /S /Q "android"  > "!output_tmp_file!" 2>&1			
		if !ERRORLEVEL! NEQ 0  (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing android directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%
		)
		call findstr /i /n /c:"!BEING_USED_BY_OTHER_PROCESS!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting android directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
		call findstr /i /n /c:"!ACCESS_DENIED!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting android directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
	)
	if exist www\ (
		call rmdir /S /Q "www"  > "!output_tmp_file!" 2>&1			
		if !ERRORLEVEL! NEQ 0  (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing www directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%
		)
		call findstr /i /n /c:"!BEING_USED_BY_OTHER_PROCESS!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting www directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
		call findstr /i /n /c:"!ACCESS_DENIED!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting www directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
	)	
	echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Unimobile project successfully cleaned.%NT%
)

echo %MOBILE_GENERATOR_LINE_PREFIX% : Validating pre-requisites... 
call :unimo_common_pre_reqs_validation
if !ERRORLEVEL! NEQ 0 (  	
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Pre-requisites validation failed^^!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the execution.%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing the above reported errors.%NT%
	exit /b %EXIT_PRE_REQ_CHECK_FAILURE_CODE%
)
echo.
:: prompt user to copy google-services.json file for FCM push notifications to under capacitor android project directory - android\app\ in ionic project root
echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : This Unimobile app is generated with out-of-the-box push notifications implementation using Firebase Cloud Messaging by AppBrahma service.%NT%
echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : There are a couple of pre-requisites that needs to be performed for building and running the app successfully.
echo 	1.Set-up Firebase Cloud Messaging for push notification in firebase console for this android app, and download google-services.json file - Reference: https://console.firebase.google.com
echo 	2.Copy this .json file to ^<unimobile_project_root^>\android\app directory. You would be prompted for this after the project is built.%NT%
echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Please be aware that the Unimobile mobile application will crash at the start up, if you do not perform the above steps^^!%NT%
echo.
echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Alternatively, for quick app testing, you can use AppBrahma generated sample FCM google-services.json and change the appID temporarily to sample apID.%NT%

:: prompt user for selection
echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Would you like to use AppBrahma generated sample FCM information for push notifications?%NT%
set "YES=Yes"
set "NO=No - I will set up FCM and download google-services.json file"
set "use_configured_info=Use already configured FCM push notification info"
set "ONE=1"
set "TWO=2"
set "THREE=3"
echo 	%SYELLOW%1^) !YES!
echo 	2^) !NO!
echo 	3^) !use_configured_info!%NT%
:prompt_back
set /p choice="%SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Please type a number shown above for selecting your option: %NT%"	
if !choice!==!ONE! (
	echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : You have chosen "1^) !YES!" as the option.%NT%
	echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Change the appID value to "com.brillium.unimobile.pn.demo" in capacitor.config.ts in the unimobile root folder ^<unimobile_project_root^>%NT%
	echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key to continue after completing the above step...%NT%
	:: wait for the user confirmation
	pause > Nul	
	call :remove_android_platform
	if !ERRORLEVEL! NEQ 0 (  	
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing android platform for updating the project^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed above. Aborting the execution.%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing the displayed errors.%NT%
		exit /b !EXIT_ANDROID_PLATFORM_REMOVE_ERROR_CODE!
	)
) else (
	if !choice!==!TWO! (
		echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : You have chosen "2^) !NO!" as the option.%NT%
		echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key to continue after downloading the google-services.json file...%NT%		
		pause > Nul
		echo %MOBILE_GENERATOR_LINE_PREFIX% : You will be prompted to copy this file to ^<unimobile_project_root^>/android/app/ folder after building ionic project.
		echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key to continue...%NT%		
		pause > Nul		
		call :remove_android_platform
		if !ERRORLEVEL! NEQ 0 (  	
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing android platform for updating the project^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed above. Aborting the execution.%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing the displayed errors.%NT%
			exit /b !EXIT_ANDROID_PLATFORM_REMOVE_ERROR_CODE!
		)
	) else (
		if !choice!==!THREE! (
			echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : You have chosen "3^) !use_configured_info!" as the option.%NT%
		) else (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You have typed an illegal value - "!choice!" - as the option.%NT%
			goto :prompt_back
		)		
	)    
)

echo !MOBILE_GENERATOR_LINE_PREFIX! : Unimobile app will be built and run for communicating with back-end server using !server_rest_api_mode! protocol.
echo %SYELLOW%!MOBILE_GENERATOR_LINE_PREFIX! : Please modify and ensure the web protocol part in "apiUrl" key value to "!server_rest_api_mode!" in src/environments/environment.ts of
echo Unimobile sources project directory and save the file to proceed further.
echo 	Example 1 - apiUrl: "!server_rest_api_mode!://192.168.0.114:8091/api"
echo 	Example 2 - apiUrl: "!server_rest_api_mode!://localhost:8091/api"
echo !MOBILE_GENERATOR_LINE_PREFIX! : Press any key to continue after modification and saving the file...%NT%
pause > Nul

:: let us ensure nested call to below function does not race around
set unimo_build_type=!build_type_all!
call :unimo_install_ionic_deps_build_and_platform
if !ERRORLEVEL! NEQ 0 (  	
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error in building the unimobile project and adding android platform^^!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed above. Aborting the execution.%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing the displayed errors.%NT%
	exit /b !EXIT_IONIC_BUILD_COMMAND_ERROR_CODE!
)

:: FCM google-services.json file copy
if !choice!==!ONE! (
	:: user chose to use AppBrahma generated sample appID FCM files and info
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Copying AppBrahma generated google-services.json from ^<unimobile_project_root^>\unimobile\samples\push-notifications\android folder to ^<unimobile_project_root^>\android\app\...
	call copy /y unimobile\samples\push-notifications\android\google-services.json android\app\ > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 (  	
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error copying AppBrahma generated sample google-services.json file. Error details are displayed below. Aborting the execution.%NT%
      	for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I
      	echo %RED%%MOBILE_GENERATOR_LINE_PREFIX% : Fix the above errors and retry running this script.%NT%
      	exit %EXIT_APB_FCM_JSON_FILE_COPY_ERROR_CODE%
	)
	echo %GREEN%%MOBILE_GENERATOR_LINE_PREFIX% : AppBrahma generated sample google-services.json copied successfully.%NT%
) else (
	if !choice!==!TWO! (
		:: user chose to generate FCM files and configure himself
		echo %YELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : As you chose to generate FCM files yourself for this Unimobile app, please complete the step of copying the downloaded google-json.json file to ^<unimobile_project_root^>/android/app/ folder now.%NT%"
    	echo %YELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Please be aware that the Unimobile mobile application will crash at the start up, if you do not perform the above step^^!%NT%
    	echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key to continue after completing the above step...%NT%	
		pause > Nul
	) 
)

:: cordova-res install check - global
call npm list -g cordova-res > "!output_tmp_file!" 2>&1
if !ERRORLEVEL! NEQ 0 (  	
	echo %MOBILE_GENERATOR_LINE_PREFIX% : cordova-res node module is not installed globally. This is needed for Unimobile app icon and splash customization.
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Installing cordova-res...
	call npm install -g cordova-res > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 (  	
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error installing cordova-res node module^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are:%NT%
		for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the execution. Please retry running this script after fixing the above reported issues.%NT%
		exit /b %EXIT_CORDOVA_RES_COMMAND_INSTALL_ERROR_CODE%	
	)	
)
echo %MOBILE_GENERATOR_LINE_PREFIX% : Customising Unimobile application icon and splash images...
call cordova-res android --skip-config --copy > "!output_tmp_file!" 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error customising the application icon and splash images^^!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are:%NT%
	for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I
    echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the execution. Please retry running this script after fixing the above reported issues.%NT%
    exit /b !EXIT_CORDOVA_RES_COMMAND_ERROR_CODE!
)
echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Customised Unimobile application icon and splash images.%NT%

:: device selection menu - check for any running emulator and take it out if found from the adb devices output
call adb devices 2>&1 > "!output_tmp_file!"
if !ERRORLEVEL! NEQ 0 ( 	
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error getting the connected devices!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : The error details are:%NT%
	call type !output_tmp_file!
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please fix the above displayed errors and retry running this script.%NT%
	exit /b %EXIT_ADB_DEVICES_COMMAND_ERROR_CODE%	
)
if exist !output_tmp_2_file! del /F !output_tmp_2_file! 2>&1
for /F "usebackq skip=1 tokens=*" %%G in ("!output_tmp_file!") do (		
	call echo %%G >> !output_tmp_2_file! 2>Nul
)
set /A menu_counter=0
if exist !output_tmp_2_file! (
	:: check for any running emulator and take it out if found from the processed adb devices output	
	set "running_emulator=emulator"	
	for /F "usebackq tokens=1,2" %%G in ("!output_tmp_2_file!") do (			
		echo %%G | findstr /i /n /c:"!running_emulator!" > Nul
		if !errorlevel! NEQ 0 (
			:: device is a non-running emulator
			set /A menu_counter+=1
			echo !menu_counter!^) %%G >> !emu_menu_opts!					
		)
	)
) 
call emulator -list-avds > "!output_tmp_file!" 2>&1	
if !ERRORLEVEL! NEQ 0 ( 	
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error getting the list of Android Virtual Devices - AVDs!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : The error details are:%NT%
	call type !output_tmp_file!
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please fix the above displayed errors and retry running this script.%NT%
	exit /b %EXIT_EMULATOR_LIST_AVDS_COMMAND_ERROR_CODE%	
) 	

echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Which device would you like to target? %NT%
:: first display connected physical devices
if exist !output_tmp_2_file! (
	call type !emu_menu_opts!
)
:: next dispay AVDs and append to emu_menu_opts
for /f "tokens=*" %%G in (!output_tmp_file!) do (
	set /A menu_counter+=1
	echo !menu_counter!^) %%G
	:: to retrive target based on user typed selection number
	echo !menu_counter!^) %%G >> !emu_menu_opts!
)
:target_sel_prompt_back
set /p choice="%SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Please type the AVD/device number shown above for selecting the target to run this Unimobile app on: %NT%"	
:: device range check
if !choice! LSS 1 (
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You have typed an illegal value - "!choice!^)" - as the option.%NT%
	goto :target_sel_prompt_back
) else (
	if !choice! GTR !menu_counter! (
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You have typed an illegal value - "!choice!^)" - as the option.%NT%
		goto :target_sel_prompt_back
	)
)
set "menu_counter="
for /f "tokens=1,2" %%G in (!emu_menu_opts!) do (	
	if %%G == !choice!^) (
		set target=%%H		
		set menu_counter=%%G
	)
)
:: remove tabs
set target=!target:	=!
:: remove spaces
set target=!target: =!
echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : You have chosen "!menu_counter! !target!" as the target%NT%

:: https check
if "!server_rest_api_mode!" == "https" (
	echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : You have chosen https for back-end server protocol. For https support by Android apps, a signed server certificate needs to be deployed onto back-end server.%NT%
	echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Please ensure back-end server is deployed with a publicly known CA signed server certificate or a self-signed server certificate.%NT%
	echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : If you are deploying self-signed ^(with or without CA^) certificate, please ensure you've deployed the back-end server's self-signed certificate onto the device you are targeting.%NT%
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Google link for certificate deployment steps: https://support.google.com/pixelphone/answer/2844832?hl=en
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Link for self-signed server certificate deployment: https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/	
	echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key to continue, after completing the above steps...%NT%
	:: wait for the user confirmation
	pause > Nul	
)

echo %MOBILE_GENERATOR_LINE_PREFIX% : Synchronizing android platform...
call ionic cap sync android  > "!output_tmp_file!" 2>&1	
if !ERRORLEVEL! NEQ 0  (			
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error synchronizing android platform^^!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
	for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 					
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing the above reported issues.%NT%
	exit /b %EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE%
) else (
	echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Synchronized capacitor android platform.%NT%
)

echo %MOBILE_GENERATOR_LINE_PREFIX% : Starting build and run process of Unimobile app for the target !target! with !server_rest_api_mode! support...
call ionic cap run android --target !target!  > "!output_tmp_file!" 2>&1	
if !ERRORLEVEL! NEQ 0  (			
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error running Unimobile app on the selected target^^!%NT%
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
	for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 					
	echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing the above reported issues.%NT%
	exit /b %EXIT_IONIC_CAP_ANDROID_RUN_COMMAND_ERROR_CODE%
)

:: configure emulator avd/device to access the server port, if running on localhost
echo %MOBILE_GENERATOR_LINE_PREFIX% : Configuring android AVD/device to access the Appbrahma server running on localhost...
call adb reverse tcp:8091 tcp:8091 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo %MOBILE_GENERATOR_LINE_PREFIX% : Error confuguring android emulator to access the server running on localhost^^!    
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Error details are:
	for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 
    echo %MOBILE_GENERATOR_LINE_PREFIX% : Please try executing the command - adb reverse tcp:8091 tcp:8091 - for establishing seamless web connection between server running on localhost and this Unimobile app running on selected target.    
    exit /b %EXIT_ADB_REVERSE_TCP_COMMAND_ERROR_CODE%
)

:: display credentials for log in - for server integrated template
echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : After the Unimobile app opens on the target you have selected:
echo 	1.Run the backend server in a seperate console using AppBrahma build and run script, if it is AppBrahma generated back-end server.
echo 	2.Use the below user credentials to log in from Unimobile app to the back-end server
echo 		%SYELLOW%%BOLD%- Admin user - Username: brahma, Password: brahma@appbrahma%NT%
echo 		%SYELLOW%%BOLD%- End user - Username: manasputhra, Password: manasputhra@appbrahma%NT%
echo.
:: delete any temp logs
if exist !output_tmp_file! (
	for /F "tokens=*" %%G in ('del /F !output_tmp_file!' ) do (									
		set "del_result=%%G"
	)		
) 
if exist !child1_output_tmp_file! (
	for /F "tokens=*" %%G in ('del /F !child1_output_tmp_file!' ) do (									
		set "del_result=%%G"
	)		
) 
if exist !emu_menu_opts! (
	for /F "tokens=*" %%G in ('del /F !emu_menu_opts!' ) do (									
		set "del_result=%%G"
	)		
) 
if exist !output_tmp_2_file! (
	for /F "tokens=*" %%G in ('del /F !output_tmp_2_file!' ) do (									
		set "del_result=%%G"
	)		
)

:: acknowledgement and best wishes
echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Wishing you best for faster quality development sprint cycles and go-live.
echo.
echo %MOBILE_GENERATOR_LINE_PREFIX% : Powered and brought to you by the passion, perseverance, and pursuit of efficiency by Brillium Technologies to transform the world through technology.
echo.
echo %MOBILE_GENERATOR_LINE_PREFIX% : Thank you for giving us the opportunity to serve you in going live quickly with your MVP by cutting down your development time and effort of the first runnable version of your full-stack product from months of team work to a few individual clicks.
echo -Team AppBrahma%NT%
echo.
echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key when ready to test your Unimobile app on the selected target...%NT%
:: wait for the user confirmation
pause > Nul
echo.	 
endlocal
exit /b 0
:: end of main script

:remove_android_platform
	if exist android\ (
		call rmdir /S /Q "android"  > "!output_tmp_file!" 2>&1			
		if !ERRORLEVEL! NEQ 0  (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing android directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%
		)
		call findstr /i /n /c:"!BEING_USED_BY_OTHER_PROCESS!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting android directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
		call findstr /i /n /c:"!ACCESS_DENIED!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting android directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
	)
	if exist www\ (
		call rmdir /S /Q "www"  > "!output_tmp_file!" 2>&1			
		if !ERRORLEVEL! NEQ 0  (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing www directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%
		)
		call findstr /i /n /c:"!BEING_USED_BY_OTHER_PROCESS!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting www directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%			
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
		call findstr /i /n /c:"!ACCESS_DENIED!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error deleting www directory for rebuilding^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors and/or manually deleting the directory.%NT%
			exit /b %EXIT_DIR_DELETE_COMMAND_ERROR_CODE%			
		)
	)	
	exit /b 0

:: function common pre-reqs check
:unimo_common_pre_reqs_validation	
	:: windows os name and version
	set "for_exec_result="
	echo %MOBILE_GENERATOR_LINE_PREFIX% : Your Windows version details are :
	for /F "tokens=*" %%G in ('systeminfo ^| findstr /B /C:"OS Name" /C:"OS Version"') do (			
		set ver_token=%%G
		set ver_token=!ver_token: =!
		for /F "tokens=1,2 delims=:" %%J in ("!ver_token!") do (
			echo 	%%J : %%K
		)				
	)
	:: nodejs install check
	call node --version 2>nul 1> nul
	if !ERRORLEVEL! NEQ 0 ( 
		:: set "exit_code=!ERRORLEVEL!"
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Nodejs is not installed or NOT in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install a stable and LTS version of nodejs major release !NODE_MAJOR_VERSION! or fix the PATH and retry running this script.%NT%
		exit /b !EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE! 
	)
	:: nodejs version check
	for /F "tokens=*" %%G in ('node --version') do (									
		set "for_exec_result=%%G"
	)	
	for /f "tokens=1,2,3 delims=." %%G in ("!for_exec_result!") do (	
		set "raw_major_ver=%%G"	
		for /f "tokens=1 delims=v" %%J in ("!raw_major_ver!") do (
			set "major_verion=%%J"
		)			
		if !major_verion! LSS %NODE_MAJOR_VERSION% (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You are running non-supported nodejs version "%%G.%%H.%%I"^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Supporeted major version is %NODE_MAJOR_VERSION%.%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the build process. Please install a stable and LTS NodeJS version of major release !NODE_MAJOR_VERSION! and retry running the script.%NT%
			exit /b %EXIT_NODE_VERSION_CHECK_COMMAND_ERROR_CODE%
		) else (
			echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : Nodejs version requirement - !for_exec_result! - met. Moving ahead with other checks...%NT%
		)
	)
	
	:: npm install check
	call npm --version 2>nul 1> nul
	if !ERRORLEVEL! NEQ 0 ( 
		:: set "exit_code=!ERRORLEVEL!"
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : npm ^(Node Package Manager^) is not installed or NOT in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install a stable and LTS version of npm major release !NPM_MAJOR_VERSION! or fix the PATH and retry running this script.%NT%
		exit /b !EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE! 
	)
	:: npm version check
	for /F "tokens=*" %%G in ('npm --version') do (									
		set "for_exec_result=%%G"
	)	
	for /f "tokens=1,2,3 delims=." %%G in ("!for_exec_result!") do (					
		if %%G LSS %NPM_MAJOR_VERSION% (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You are running non-supported npm major version %%G.%%H.%%I^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Supported major version is %NPM_MAJOR_VERSION%.%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the build process. Please install a stable and LTS npm version of major release !NPM_MAJOR_VERSION! and retry running this script.%NT%
			exit /b %EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE%
		) else (
			echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : NPM version requirement - !for_exec_result! - met. Moving ahead with other checks...%NT%
		)
	)
	
	:: ionic cli install check
	call ionic --version 2>nul 1> nul
	if !ERRORLEVEL! NEQ 0 ( 
		:: set "exit_code=!ERRORLEVEL!"
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Ionic CLI is NOT installed or not in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install a stable and LTS version of Ionic CLI major release %IONIC_CLI_MAJOR_VERSION% or fix the PATH and retry running this script.%NT%
		exit /b !EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE! 
	)
	:: ionic cli version check
	for /F "tokens=*" %%G in ('ionic --version') do (									
		set "for_exec_result=%%G"
	)	
	for /f "tokens=1,2,3 delims=." %%G in ("!for_exec_result!") do (		
		if %%G LSS %IONIC_CLI_MAJOR_VERSION% (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You are running non-supported ionic version %%G.%%H.%%I^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Supported major version is %IONIC_CLI_MAJOR_VERSION%%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the build process. Please install a stable and LTS Ionic CLI version of major release %IONIC_CLI_MAJOR_VERSION% and retry running this script.%NT%
			exit /b %EXIT_NPM_VERSION_CHECK_COMMAND_ERROR_CODE%
		) else (
			echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : Ionic CLI version requirement - !for_exec_result! - met. Moving ahead with other checks...%NT%
		)
	)
	
	:: Java install check
	call java -version 2>nul 1> nul
	if !ERRORLEVEL! NEQ 0 ( 
		:: set "exit_code=!ERRORLEVEL!"
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Java runtime is not installed or NOT in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install a stable and LTS version of Java runtime/JDK major release %JAVA_MIN_MAJOR_VERSION% or fix the PATH and retry running this script.%NT%
		exit /b !EXIT_JAVA_VERSION_CHECK_COMMAND_ERROR_CODE! 
	)
	:: java runtime version check
	set "first_line_string="
	set "first_line=1"
	for /F "tokens=*" %%G in ('java -version  2^>^&1 1^> nul') do (	
		if !first_line! EQU 1 (
			set "first_line_string=%%G"
			set /a first_line=!first_line!+1
		)	
	)	
	set "third_token="
	::  percent~I on commandline or percent percent~I in batch file expands percent I removing any surrounding quotes	
	for /F "tokens=1,2,3,4,5 delims= " %%G in ("!first_line_string!") do (			
		set "third_token=%%~I"		
	)
	set "java_major_version="
	set "java_minor_version="
	set "java_patch_version="
	for /F "tokens=1,2,3 delims=." %%G in ("!third_token!") do (
		set java_major_version=%%G
		set java_minor_version=%%H
		set java_patch_version=%%I
	)
	set first_part_mis_match=0
	set second_part_mis_match=0
	if !java_major_version! LSS %JAVA_MIN_MAJOR_VERSION% (
		set first_part_mis_match=1
	)
	if !java_minor_version! LSS %JAVA_MIN_MINOR_VERSION% (
		set second_part_mis_match=1
	)

	if first_part_mis_match EQU second_part_mis_match (
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : You are running non-supported Java runtime version !third_token!^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Suppoted major version is %JAVA_MIN_MAJOR_VERSION%%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Aborting the build process. Please install a stable and LTS java release of major version %JAVA_MIN_MAJOR_VERSION% and retry running this script.%NT%
		exit /b %EXIT_JAVA_VERSION_CHECK_COMMAND_ERROR_CODE%
	) else (
		echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : Java runtime version requirement - !third_token! - met. Moving ahead with other checks...%NT%
	)
	
	:: jdk install check
	call javac --version  2>nul 1>nul
	if !ERRORLEVEL! NEQ 0 (
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Java JDK is not installed or NOT in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install a stable and LTS Java JDK version of major release !JAVA_MIN_MAJOR_VERSION! or fix the PATH and retry running this script.%NT%
		exit /b %EXIT_JDK_VERSION_CHECK_COMMAND_ERROR_CODE%
	) else (
		echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : Java JDK found in the path. Moving ahead with other checks...%NT%
	)
	
	:: android environment variables check - android_home, platform-tools, emulator, tools\bin	
	if exist !output_tmp_file! del /F !output_tmp_file!
	call echo %ANDROID_HOME% 2>&1 | find /i "android\sdk" > !output_tmp_file! 2>&1
	:: if the find result is empty writing to file results in error raising errorlevel to non-zero
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : ANDROID_HOME environment varible is not set^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please set this variable value - usually !USERPROFILE!\AppData\Local\Android\Sdk - and retry running this script.%NT%
		exit /b %EXIT_ANDROID_HOME_NOT_SET_CODE%
	)
	
	call echo %PATH% 2>&1 | find /i "android\sdk" > !output_tmp_file! 2>&1	
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Android SDK path is NOT set in PATH environment variable^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please set this path value - usually !USERPROFILE!\AppData\Local\Android\Sdk - and retry running this script.%NT%
		exit /b %EXIT_ANDROID_SDK_PATH_NOT_SET_IN_PATH_CODE%
	)

	call echo %PATH% 2>&1 | find /i "android\sdk\platform-tools" > !output_tmp_file! 2>&1	
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Android SDK Platform tools path is NOT set in PATH environment variable^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please set this path value - usually !USERPROFILE!\AppData\Local\Android\Sdk\platform-tools - and retry running this script.%NT%
		exit /b %EXIT_ANDROID_PLATFORM_TOOLS_NOT_IN_PATH_CODE%
	)

	:: call echo %PATH% 2>&1 | find /i "android\sdk\emulator" > !output_tmp_file! 2>&1	
	call echo %PATH% 2>&1 | find /i "android\sdk\emulator" > !output_tmp_file! 2>&1	
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Android emulator is NOT installed or executable path is NOT set in PATH environment variable^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Usually the relevant path is !USERPROFILE!\AppData\Local\Android\Sdk\emulator%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install or set the emulator path in PATH and retry running this script.%NT%
		exit /b %EXIT_EMULATOR_EXE_PATH_NOT_PROPERLY_SET_CODE%
	)

	call where emulator 2>&1 | find /i "android\sdk\emulator\emulator.exe" > !output_tmp_file! 2>&1	
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Android emulator path is NOT set at all or not set properly in PATH environment variable^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Usually the relevant path is !USERPROFILE!\AppData\Local\Android\Sdk\emulator%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install or set proper emulator executable path value in PATH and retry running this script.%NT%
		exit /b %EXIT_EMULATOR_EXE_PATH_NOT_PROPERLY_SET_CODE%
	)

	if exist !output_tmp_file! del /F !output_tmp_file!
	call echo %PATH% 2>&1 | find /i "android\sdk\tools\bin" > !output_tmp_file! 2>&1	
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Android SDK tools is NOT installed or its path is NOT set in PATH environment variable^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install or set this path value - usually !USERPROFILE!\AppData\Local\Android\Sdk\tools\bin - and retry running this script.%NT%
		exit /b %EXIT_ANDROID_SDK_TOOLS_NOT_SET_IN_PATH_CODE%
	)
	
	:: adb command check
	call adb --version 2>&1 > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 ( 				
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : adb command executable path is not found. Either Android SDK tools not installed or adb executable path is NOT set in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install the same and/or set the PATH variable and retry running this script.%NT%
		exit /b %EXIT_ADB_VERSION_COMMAND_ERROR_CODE%
	) else (
		echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : adb executable is found to be in the PATH. Moving ahead with other checks...%NT%
	)
	
	:: emulator command check
	:: call emulator -help 2>&1 > "!output_tmp_file!" 2>&1
	call emulator -help 2>&1 > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 ( 		
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Emulator command executable path is not found. Either Android SDK tools not installed or emulator executable path is NOT set in PATH^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please install the same and/or set the PATH variable and retry running this script.%NT%
		exit /b %EXIT_EMULATOR_HELP_COMMAND_ERROR_CODE%
	) else (
		echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : Emulator executable is found to be in the PATH. Moving ahead with other checks...%NT%
	)
	::for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 
	
	:: at least one AVD should be configured
	call emulator -list-avds 2>&1 > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 ( 		
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error getting the configured AVDs^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : The error details are:%NT%
		for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please fix emulator command execution errors displayed above and retry running this script.%NT%
		exit /b %EXIT_EMULATOR_LIST_AVDS_COMMAND_ERROR_CODE%
	)
	:: get configured AVDs count
	set /A avds=0
	for /F %%a in ('findstr /R . "!output_tmp_file!"') do (set /A avds=!avds!+1)
	if !avds! LSS 1 ( 	
		echo.	
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Not a single Android Virtual Device - AVD - or Emulator image is set up^^!		
		echo %MOBILE_GENERATOR_LINE_PREFIX% : If you want to run the unimobile app on emulator, please abort this script execution right now by pressing Ctrl+C, configure at least one AVD, and retry running this script.				
		echo %MOBILE_GENERATOR_LINE_PREFIX% : Else, if you would like to run the Unimobile app directly on a connected android device, please ensure an android device is connected and USB debug options are enabled on this device and then proceed ahead.%NT%
		echo.
		echo %SYELLOW%%MOBILE_GENERATOR_LINE_PREFIX% : Press any key to continue after connecting and setting up android device to this computer...%NT%
		:: wait for the user confirmation
		pause > Nul
		echo.		
	) else (
		echo %BOLD%%MOBILE_GENERATOR_LINE_PREFIX% : Found "!avds!" AVDs configured for the emulator%NT%
	)
	:: conected devices check	
	call adb devices 2>&1 > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 ( 	
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error getting the connected devices!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : The error details are:%NT%
		call type !output_tmp_file!
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please fix above displayed errors and retry running this script.%NT%
		exit /b %EXIT_ADB_DEVICES_COMMAND_ERROR_CODE%		
	) 	
	set "phones=" 
	for /F "usebackq skip=1 tokens=*" %%G in ("!output_tmp_file!") do (	
		set "phones=!phones! %%G"
	)	
	:: check for empty value of phones
	if [!phones!]==[] (		
		if !avds! LSS 1 ( 	
			echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Not a single connected android device nor an AVD found!%NT%
			echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Please set up at least one AVD or connect an android device and retry running this script.%NT%
			exit /b !EXIT_ADB_DEVICES_COMMAND_ERROR_CODE!		
		)		
	) else (
		echo %BOLD%!MOBILE_GENERATOR_LINE_PREFIX! : Found connected android device^(s^)^:!phones!%NT%
	)
	echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Pre-requisites validation completed successfully.%NT%
	exit /b 0

:: function to build unimo app
:unimo_install_ionic_deps_build_and_platform
	setlocal EnableDelayedExpansion		
	:: check the type of action to take for it could have been a nested call	
	if !unimo_build_type! EQU !build_type_android_platform_reinstall! (
		:: any special handling for re-adding cap android platform
		echo !MOBILE_GENERATOR_LINE_PREFIX! : Now re-adding capacitor android platform...
		call :add_cap_platform
		if !ERRORLEVEL! NEQ 0 ( 
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error re-adding capacitor android platform^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed above. Aborting Unimobile build and run process.%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing above reported errors.%NT%
			exit /b %EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE%						
		) else (
			:: sync it after adding the platform
			echo %MOBILE_GENERATOR_LINE_PREFIX% : Synchronizing capacitor android platform...	
			call ionic cap sync android  > "!output_tmp_file!" 2>&1	
			if !ERRORLEVEL! NEQ 0  (			
				echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error synchronizing android platform^^!%NT%
				echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
				for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 									
				exit /b %EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE%
			) else (
				echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Synchronized capacitor android platform.%NT%
				exit /b 0
			)	
		)
		exit /b 0	
	)
	if !unimo_build_type! EQU !build_type_redo_deps_build_cap_android_platform! (
		:: any special handling for redoing the deps and build
		echo !MOBILE_GENERATOR_LINE_PREFIX! : Re-building the unimobile app...
	)	
	if !unimo_build_type! EQU !build_type_all! (
		:: any special handling for build all
		echo !MOBILE_GENERATOR_LINE_PREFIX! : Building the unimobile app...
	)

	echo !MOBILE_GENERATOR_LINE_PREFIX! : Installing node dependencies...
	call :npm_install
	if !ERRORLEVEL! NEQ 0 (  	
		echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Error installing node dependencies^^!%NT%
		echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Error details are displayed above. Please fix these issues and re-run this script.%NT%
		exit /b !EXIT_NPM_INSTALL_COMMAND_ERROR_CODE!
	)	
	echo %SGREEN%!MOBILE_GENERATOR_LINE_PREFIX! : Installed node dependencies.%NT%

	echo !MOBILE_GENERATOR_LINE_PREFIX! : Now building the project...
	call :ionic_build
	if !ERRORLEVEL! NEQ 0 (  	
		echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Error building the project^^!%NT%
		echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Error details are displayed above. Please fix these issues and re-run this script.%NT%
		exit /b !EXIT_IONIC_BUILD_COMMAND_ERROR_CODE!
	)	
	echo %SGREEN%!MOBILE_GENERATOR_LINE_PREFIX! : Project built successfully...%NT%

	echo !MOBILE_GENERATOR_LINE_PREFIX! : Now adding capacitor android platform...
	call :add_cap_platform
	if !ERRORLEVEL! NEQ 0 (  	
		if !ERRORLEVEL! EQU !EXIT_IONIC_REINSTALL_CAP_ANDROID_PLATFORM! (  	
			set unimo_build_type=!build_type_android_platform_reinstall!
			call :unimo_install_ionic_deps_build_and_platform
		) else (
			if !ERRORLEVEL! EQU !EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD! (  	
				set unimo_build_type=!build_type_redo_deps_build_cap_android_platform!
				call :unimo_install_ionic_deps_build_and_platform
			) else (										
				exit /b !EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE!
			)
		)
	) else (		
		exit /b 0
	)
	set "exit_code=!ERRORLEVEL!"
	exit /b !exit_code!

:: function to install node dependencies
:npm_install
	setlocal EnableDelayedExpansion		
	call npm install > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 (
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error installing node dependencies^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Fixing the errors...%NT%
		call rmdir /S /Q "node_modules" > "!output_tmp_file!" 2>&1			
		if !ERRORLEVEL! NEQ 0  (
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing node_modules directory for fixing dependencies install errors^^!%NT%
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting the execution.%NT%
			for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 								
			echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors.%NT%			
			exit /b %EXIT_NPM_INSTALL_COMMAND_ERROR_CODE%
		) else (							
			call :npm_reinstall
			if !ERRORLEVEL! NEQ 0 (
				set "exit_code=!ERRORLEVEL!"
				exit /b !exit_code!
			) else (
				exit /b 0
			)
		)			
	) else (		
		exit /b 0
	)	
	set "exit_code=!ERRORLEVEL!"
	exit /b !exit_code!

:npm_reinstall	
	setlocal EnableDelayedExpansion	
	call npm install --force > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 (
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Re-attempt to install node dependencies resulted in error^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
		for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 		
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running this script after fixing these issues.%NT%
		exit /b %EXIT_NPM_INSTALL_COMMAND_ERROR_CODE%		
	) else ( 		
		exit /b 0
	)
	set "exit_code=!ERRORLEVEL!"
	exit /b !exit_code!		

:ionic_build
	setlocal EnableDelayedExpansion	
	call ionic build > "!output_tmp_file!" 2>&1
	if !ERRORLEVEL! NEQ 0 (
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error building unimobile app project^^!%NT%
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
		for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 
		echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Please retry running the script after fixing these reported errors.%NT%
		exit /b %EXIT_IONIC_BUILD_COMMAND_ERROR_CODE%
	) else ( 		
		exit /b 0
	)
	set "exit_code=!ERRORLEVEL!"
	exit /b !exit_code!	
	
:: function to add capacitor android platform and handle errors
:add_cap_platform
	setlocal EnableDelayedExpansion				
	call ionic capacitor add android > "!output_tmp_file!" 2>&1	
	if !ERRORLEVEL! NEQ 0 (		
		echo %SYELLOW%!MOBILE_GENERATOR_LINE_PREFIX! : Found issues in adding android platform^^!%NT%
		echo %SYELLOW%!MOBILE_GENERATOR_LINE_PREFIX! : Diagnosing for the root cause...%NT%
		:: look for error strings in the output for further action
		call findstr /i /n /c:"!PLATFORM_ALREADY_INSTALLED!" "!output_tmp_file!" > Nul			
		if !ERRORLEVEL! EQU 0 (
			echo !MOBILE_GENERATOR_LINE_PREFIX! : Android platform was already added^^!
			echo %MOBILE_GENERATOR_LINE_PREFIX% : Synchronizing capacitor android platform...	
			call ionic cap sync android  > "!output_tmp_file!" 2>&1	
			if !ERRORLEVEL! NEQ 0  (			
				echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error synchronizing android platform^^!%NT%
				echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
				for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 									
				exit /b %EXIT_IONIC_CAP_ANDROID_PROJ_SYNC_COMMAND_ERROR_CODE%
			) else (
				echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Synchronized capacitor android platform.%NT%
				exit /b 0
			)			
		) else (
			call findstr /i /n /c:"!CAP_CLI_ERROR!" "!output_tmp_file!" > Nul    					
			if !ERRORLEVEL! EQU 0 (
				echo %SYELLOW%!MOBILE_GENERATOR_LINE_PREFIX! : Capacitor version incompatibilities found. Fixing the incompatibilities...%NT%
				call rmdir /S /Q android node_modules www > "!output_tmp_file!" 2>&1			
				if !ERRORLEVEL! NEQ 0  (
					echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error removing node_modules, android, and www directories for fixing capacitor incompatibilities for android platform^^!%NT%
					echo %SRED%%MOBILE_GENERATOR_LINE_PREFIX% : Error details are displayed below. Aborting Unimobile build and run process.%NT%
					for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 					
					echo.
					exit /b %EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE%
				) else (
					exit /b !EXIT_IONIC_RE_RUN_INSTALL_AND_BUILD!	
				)				
			) else (
				echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Error adding capacitor android platform^^!%NT%
				echo %SRED%!MOBILE_GENERATOR_LINE_PREFIX! : Error details are displayed below. Aborting Unimobile build and run process.%NT%
				for /F "usebackq delims=" %%I in ("!output_tmp_file!") do echo %%I 	
				echo.				
				exit /b !EXIT_IONIC_CAP_ADD_PLATFORM_COMMAND_ERROR_CODE!
			)
		)	
	) else (	
		echo %SGREEN%%MOBILE_GENERATOR_LINE_PREFIX% : Added capacitor android platform.%NT%
		exit /b 0		
	)	
	set "exit_code=!ERRORLEVEL!"
	exit /b !exit_code!

:: End of the script
