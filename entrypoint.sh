#!/bin/bash
set -e

INPUT_REQUIREMENTS_TXT=$1
INPUT_LAMBDA_LAYER_ARN=$2
INPUT_LAMBDA_FUNCTION_NAME=$3
INPUT_PYTHON_VERSION=$4

echo "Requested Python version: $INPUT_PYTHON_VERSION"

apt-get update
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update
apt-get install -y python${INPUT_PYTHON_VERSION} python${INPUT_PYTHON_VERSION}-dev python${INPUT_PYTHON_VERSION}-distutils python3-pip

curl -sS https://bootstrap.pypa.io/get-pip.py | python${INPUT_PYTHON_VERSION}

PYTHON_BIN=python${INPUT_PYTHON_VERSION}

echo "Using Python binary: $PYTHON_BIN"

echo "Using Python version: $($PYTHON_BIN --version)"
echo "Using pip version: $($PYTHON_BIN -m pip --version)"

install_zip_dependencies() {
    echo "Installing and zipping dependencies..."
    mkdir python
    $PYTHON_BIN -m pip install --upgrade pip
    $PYTHON_BIN -m pip install awscli
    $PYTHON_BIN -m pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
    zip -r dependencies.zip ./python
}

publish_dependencies_as_layer() {
    echo "Publishing dependencies as a layer..."
    local result
    result=$(aws lambda publish-layer-version --layer-name "${INPUT_LAMBDA_LAYER_ARN}" --zip-file fileb://dependencies.zip --compatible-runtimes python${INPUT_PYTHON_VERSION})
    LAYER_VERSION=$(jq '.Version' <<< "$result")
    rm -rf python dependencies.zip
}

publish_function_code() {
    echo "Deploying the code..."
    zip -r code.zip . -x '*.git*'
    aws lambda update-function-code --function-name "${INPUT_LAMBDA_FUNCTION_NAME}" --zip-file fileb://code.zip
    rm code.zip
}

update_function_layers() {
    echo "Updating function to use new layer..."
    aws lambda update-function-configuration --function-name "${INPUT_LAMBDA_FUNCTION_NAME}" --layers "${INPUT_LAMBDA_LAYER_ARN}:${LAYER_VERSION}"
}

deploy_lambda_function() {
    install_zip_dependencies
    publish_dependencies_as_layer
    publish_function_code
    sleep 5s
    update_function_layers
}

deploy_lambda_function
echo "Done."
