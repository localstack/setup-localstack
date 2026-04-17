# Changelog

## [0.3.2]

### Notes

- **First immutable release.** This is the first release published with [GitHub Immutable Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-immutable-releases) enabled on the repository. The `v0.3.2` tag and its assets cannot be modified or deleted, and the release carries a signed attestation. Users are encouraged to pin to `v0.3.2` (or later) for supply-chain hardening.

## [0.3.1]

- Only show `use-pro` deprecation message on top action input ([#67](https://github.com/LocalStack/setup-localstack/pull/67)).

## [0.3.0]

### Breaking Changes

- **`use-pro` now defaults to `true`.** The action will use the `localstack/localstack-pro` image by default. Workflows that relied on the community image without setting `use-pro` will now get the Pro image, which requires a `LOCALSTACK_AUTH_TOKEN`. Set `use-pro: 'false'` explicitly if you need the community image. For newer versions of LocalStack these images are equivalent.

### Deprecated

- **`use-pro` input will be removed in a future release as we are consolidating our docker images**.

