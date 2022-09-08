# Setup LocalStack

[![LocalStack Test](https://github.com/HarshCasper/setup-localstack/actions/workflows/ci.yml/badge.svg)](https://github.com/HarshCasper/setup-localstack/actions/workflows/ci.yml)


A GitHub Action to setup [LocalStack](https://github.com/localstack/localstack) on your GitHub Actions runner workflow by:

- Pulling a specific version of the LocalStack Docker Image into the GitHub Action runner.
- Configuring the [LocalStack CLI](https://docs.localstack.cloud/get-started/#localstack-cli) to launch the Docker container with an optional API token for pro usage.
- Installing [LocalStack AWS CLI](https://github.com/localstack/awscli-local), a thin wrapper around the `aws` command line interface for use with LocalStack to run integration tests over AWS services.

## Usage

To get started, you can use this minimal example:

```yml
- name: Start LocalStack
  uses: HarshCasper/setup-localstack@v0.1.1
  with:
    image-tag: 'latest'
    install-awslocal: 'true'
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
```

### Inputs

|Input|Description  |Default
|--|--|--|
|`image-tag`  |Tag of the LocalStack Docker image to use  |`latest`
|`install-awslocal`  |Whether to install the `awslocal` CLI into the build environment  | `true`

### Example workflow

```yml
name: LocalStack Test
on: [ push, pull_request ]

jobs:
  localstack-action-test:
    name: 'Test LocalStack GitHub Action'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Start LocalStack
        uses: HarshCasper/setup-localstack@v0.1.1
        with:
          image-tag: 'latest'
          install-awslocal: 'true'
        env:
          LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}

      - name: Run Tests against LocalStack
        run: |
          awslocal s3 mb s3://test
          awslocal s3 ls
          echo "Test Execution complete!" 
```

## License

[MIT License](LICENSE)
