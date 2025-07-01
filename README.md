# Python AWS Lambda Deploy

[![GitHubActions](https://img.shields.io/badge/listed%20on-GitHubActions-blue.svg)](https://github.com/marketplace/actions/python-aws-lambda-deploy)

A GitHub Action to deploy AWS Lambda functions written in Python, allowing you to specify any Python version supported by Lambda. Dependencies are packaged in a separate Lambda layer.

## Features

- Supports custom Python versions (e.g., 3.7, 3.8, 3.9, 3.10 ...)
- Packages dependencies into a Lambda layer
- Deploys Lambda code and updates the function to use the new layer

| ⚠️ Warning                               | 
|------------------------------------------|
| **This doesn't work with numpy library**. For numpy library layer setup check [here](https://github.com/numpy/numpy/issues/15669)     |

## Prerequisites

Use `actions/checkout` before this action to pull your code.

## Structure

- Lambda code in the root of your repo or subdirectory as you usually deploy.
- Dependencies listed in a `requirements.txt` (or another file you specify).

## Inputs

| Input              | Description                                                       | Default            |
|--------------------|-------------------------------------------------------------------|--------------------|
| `lambda_layer_arn` | ARN of the Lambda layer (without version)                         |                    |
| `lambda_function_name` | Lambda function name or ARN                                   |                    |
| `requirements_txt` | Path to your `requirements.txt` file                              | `requirements.txt` |
| `python_version`   | Python version to use for building dependencies (e.g., 3.9)       | `3.12`             |

## Example workflow

```yaml
name: deploy-py-lambda
on:
  push:
    branches:
      - main
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@master
    - name: Deploy code to Lambda
      uses: arthiondaena/py-lambda-deploy@v1.0
      with:
        lambda_layer_arn: 'arn:aws:lambda:us-east-1:123445678987:layer:Hello_world2'
        lambda_function_name: 'arn:aws:lambda:us-east-1:123445678987:function:Hello_world_2'
        python_version: '3.10'
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_DEFAULT_REGION: 'us-east-1'
```