# Changelog

## [0.3.0]

### Breaking Changes

- **`use-pro` now defaults to `true`.** The action will use the `localstack/localstack-pro` image by default. Workflows that relied on the community image without setting `use-pro` will now get the Pro image, which requires a `LOCALSTACK_AUTH_TOKEN`. Set `use-pro: 'false'` explicitly if you need the community image. For newer versions of LocalStack these images are equivalent.

### Deprecated

- **`use-pro` input will be removed in a future release as we are consolidating our docker images**.

