# S3 Sync GitHub Action

Sync a directory to an AWS S3 bucket as part of your CI/CD pipeline. Supports OIDC authentication and S3-compatible endpoints.

## Features
- Upload build artifacts or any directory to S3
- Supports AWS OIDC (no static secrets required)
- Works with AWS S3 and S3-compatible storage (MinIO, Ceph, etc.)
- Minimal, secure, and production-ready

## Inputs
| Name             | Description                                      | Required | Default      |
|------------------|--------------------------------------------------|----------|--------------|
| aws_s3_bucket    | Target S3 bucket name                            | Yes      |              |
| source_dir       | Local directory to sync to S3                    | Yes      | .            |
| dest_dir         | Destination path in the S3 bucket                | Yes      |              |
| aws_s3_endpoint  | Custom S3 endpoint URL (for S3-compatible)       | No       |              |
| aws_region       | AWS region                                       | No       | us-east-2    |

## Permissions
This action requires the following GitHub Actions permissions:
- `id-token: write` (for OIDC)
- `contents: read` (to checkout code)

The AWS IAM role must allow `s3:PutObject`, `s3:ListBucket` for the target bucket.

## Usage
```yaml
jobs:
  upload-artifacts:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::<account>:role/<role>
          aws-region: us-east-2
      - name: Build artifact
        run: |
          mkdir -p dist
          echo "artifact" > dist/file.txt
      - name: Upload to S3
        uses: ./s3-sync-action
        with:
          aws_s3_bucket: my-bucket
          source_dir: dist
          dest_dir: artifacts/${{ github.sha }}
```

## S3-Compatible Example (MinIO, Ceph, etc.)
```yaml
      - name: Upload to S3-compatible storage
        uses: ./s3-sync-action
        with:
          aws_s3_bucket: my-bucket
          source_dir: dist
          dest_dir: artifacts/${{ github.sha }}
          aws_s3_endpoint: http://localhost:9000
          aws_region: us-east-1
```
