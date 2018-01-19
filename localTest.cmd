@echo OFF
setlocal

REM The number of tests to run in parallel
set PARALLEL_DEPLOYMENT_NUMBER=6

REM The endpoint that our validate and deploy requests will be sent to
set VALIDATION_HOST=http://qst9494f4f5c44dd94d84049.westus.cloudapp.azure.com

REM Whether to skip the remote validate test or not.
set VALIDATION_SKIP_VALIDATE=true

REM Whether to skip the remote deploy test or not.
set VALIDATION_SKIP_DEPLOY=true

call mocha
endlocal