Actions Runner Image
====================

The runner image for Matchory's self-hosted GitHub Actions runners (the ARC scale sets on the
`aks-ci-runners` cluster). Published to `ghcr.io/matchory/actions-runner`.

It extends the upstream [`actions-runner`](https://github.com/actions/runner) image, which is
far more minimal than GitHub's hosted runners, with the tools our workflows expect:

- **PHP 8.5** with the packages `shivammathur/setup-php` installs on self-hosted runners, so
  setup-php finds them present instead of installing PHP on every job
- **psql** (PostgreSQL 16 client), which loads the webapp's schema baseline in its tests
- **libatomic**, which the pnpm binary links against

Upstream security fixes are applied at build time, and the image is rebuilt every Monday.

## Building

```bash
docker buildx build --platform linux/amd64 --load -t actions-runner:local .
```

Bump `PHP_VERSION` in the `Dockerfile` together with the `php-version` the workflows pass
to setup-php; if they differ, setup-php installs its own PHP again.

## Using it

Reference the image by digest in the scale set's Helm values (`template.spec.containers[0].image`).
Each build's digest is in the workflow summary; verify it with

```bash
gh attestation verify oci://ghcr.io/matchory/actions-runner@<digest> --owner matchory
```
