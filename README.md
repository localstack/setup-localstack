# Setup LocalStack

[![LocalStack Test](https://github.com/LocalStack/setup-localstack/actions/workflows/ci.yml/badge.svg)](https://github.com/LocalStack/setup-localstack/actions/workflows/ci.yml)


A GitHub Action to setup [LocalStack](https://github.com/localstack/localstack) on your GitHub Actions runner workflow by:

- Pulling a specific version of the LocalStack Docker Image into the GitHub Action runner.
- Configuring the [LocalStack CLI](https://docs.localstack.cloud/get-started/#localstack-cli) to launch the Docker container with an optional API token for pro usage.
- Installing [LocalStack AWS CLI](https://github.com/localstack/awscli-local), a thin wrapper around the `aws` command line interface for use with LocalStack to run integration tests over AWS services.
- Export/import [LocalStack state](https://docs.localstack.cloud/user-guide/state-management/export-import-state/) as an artifact
- Save/load [LocalStack Cloud Pods](https://docs.localstack.cloud/user-guide/state-management/cloud-pods/)
- Start/stop a [LocalStack Ephemeral Instance](https://docs.localstack.cloud/user-guide/cloud-sandbox/ephemeral-instance/) _(PREVIEW)_

## Usage

### Get started with a minimal example

```yml
- name: Start LocalStack
  uses: LocalStack/setup-localstack@v0.2.2
  with:
    image-tag: 'latest'
    install-awslocal: 'true'
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
```
> **NOTE**: The `LOCALSTACK_API_KEY` environment variable is required to be set if `use-pro` is set to `true`.  
If the key is not found LocalStack by default falls back to the CE edition and displays a warning.

### Install only CLIs and startup later
```yml
- name: Install LocalStack CLIs
  uses: LocalStack/setup-localstack@v0.2.2
  with:
    skip-startup: 'true'
    install-awslocal: 'true'

...

- name: Start LocalStack
  uses: LocalStack/setup-localstack@v0.2.2
  with:
    image-tag: 'latest'
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
```

### Save a state later on in the pipeline
```yml
- name: Save LocalStack State
  uses: LocalStack/setup-localstack@v0.2.2
  with:
    install-awslocal: 'true'
    state-backend: cloud-pods
    state-action: save
    state-name: my-cloud-pod
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
```
> **NOTE**: The `LOCALSTACK_API_KEY` environment variable is required to be set to save/load LocalStack's state either as a Cloud Pod or as a file artifact.

### Load an already saved state
```yml
- name: Start LocalStack and Load State
  uses: LocalStack/setup-localstack@v0.2.2
  with:
    install-awslocal: 'true'
    state-backend: cloud-pods
    state-action: load
    state-name: my-cloud-pod
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
```
> **NOTE**: To load a **local state** from a different GitHub Actions workflow, one must set the `WORKFLOW_ID` environment variable.

> **NOTE**: The `LOCALSTACK_API_KEY` environment variable is required to be set to **save/load** LocalStack's state either as a Cloud Pod or as a file artifact.

### Manage Application Previews (on an Ephemeral Instance)
```yml
uses: LocalStack/setup-localstack@$v0.2.0
  with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
      state-backend: ephemeral
      state-action: start
      # Adding this option prevents Ephemeral Instance to be stopped after the `preview-cmd` run
      skip-ephemeral-stop: 'true'
      # Optional script/command to run
      preview-cmd: deploy.sh
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}

...

with:
  uses: LocalStack/setup-localstack@${{ env.GH_ACTION_VERSION }}
  with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
      state-backend: ephemeral
      state-action: stop
  env:
    LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
```

## Inputs

| Input              | Description                                                                      | Default  |
| ------------------ | -------------------------------------------------------------------------------- | -------- |
| `auto-load-pod`    | Which pod to load on startup of LocalStack  (application preview)                | `None`   |
| `ci-project`          | Name of the CI project to track in LocalStack Cloud |  |
| `configuration`    | Configuration variables to use while starting LocalStack container               | `None`   |
| `extension-auto-install` | Which extensions to install on startup of LocalStack (application preview) | `None`   | 
| `github-token`          | Github token used to create PR comments |  |
| `image-tag`        | Tag of the LocalStack Docker image to use                                        | `latest` |
| `include-preview`          | Whether to include the created Ephemeral Instance URL in the PR comment | `false` |
| `install-awslocal` | Whether to install the `awslocal` CLI into the build environment                 | `true`   |
| `lifetime`         | How long an ephemeral instance should live                                       | 30       |
| `preview-cmd`          | Command(s) used to create a Ephemeral Instance of the PR (can use `$AWS_ENDPOINT_URL`) |  |
| `skip-ephemeral-stop`        | Skip stopping LocalStack Ephemeral Instance | `false`  |
| `skip-startup`     | Explicitly prevent LocalStack start up, only installs CLI(s). Recommended to manage state later on in the pipeline or start up an ephemeral instance. | `false`  |
| `skip-wait`        | Skip waiting for LocalStack to start up | `false`  |
| `state-action`     | Valid values are `load`, `save`, `start`, `stop`, `` (empty, don't manage state). Values `start`/`stop` only usable with app previews.  | `` |
| `state-backend`    | Either store the state of LocalStack locally, as a Cloud Pod or start an Ephemeral Instance. Valid values are `cloud-pods`, `ephemeral` or `local`. Use this option in unison with `state-action` to control behaviour. | `cloud-pods`  |
| `state-name`       | Name of the state artifact (without extension) | `false`  |
| `use-pro`          | Whether to use the Pro version of LocalStack (requires API key to be configured) | `false`  |

## Example workflow
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
        uses: LocalStack/setup-localstack@v0.2.2
        with:
          image-tag: 'latest'
          install-awslocal: 'true'
          configuration: DEBUG=1
          use-pro: 'true'
          state-backend: cloud-pods
          state-action: load
          state-name: my-cloud-pod
        env:
          LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}

      - name: Run Tests against LocalStack
        run: |
          awslocal s3 mb s3://test
          awslocal s3 ls
          echo "Test Execution complete!"

      - name: Save LocalStack State
        uses: LocalStack/setup-localstack@v0.2.2
        with:
          state-backend: local
          state-action: save
          state-name: my-ls-state-artifact
        env:
          LOCALSTACK_API_KEY: ${{ secrets.LOCALSTACK_API_KEY }}
          WORKFLOW_ID: ${{ env.MY_GOLDEN_LS_STATE }}
```

## License

[MIT License](LICENSE)
