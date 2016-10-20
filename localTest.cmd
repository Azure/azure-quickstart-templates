setlocal
REM set VALIDATE_MODIFIED_ONLY=false
set PARALLEL_DEPLOYMENT_NUMBER=6
set VALIDATION_HOST=http://qst9494f4f5c44dd94d84049.westus.cloudapp.azure.com

REM set VALIDATION_SKIP_VALIDATE=true
set VALIDATION_SKIP_DEPLOY=true

call mocha
endlocal