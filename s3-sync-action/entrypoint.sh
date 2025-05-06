#!/bin/sh
set -e

# Validate required environment variables
if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting." >&2
  exit 1
fi
if [ -z "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR is not set. Quitting." >&2
  exit 1
fi
if [ -z "$DEST_DIR" ]; then
  echo "DEST_DIR is not set. Quitting." >&2
  exit 1
fi

# Set default region if not provided
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-2"
fi

# Optional: custom S3 endpoint
ENDPOINT_ARGS=""
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_ARGS="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Determine commit SHA for versioning (fallback to timestamp if not set)
COMMIT_SHA="${GITHUB_SHA:-$(date +%s)}"

# Sync to versioned path (idempotent for same source/commit)
aws s3 sync "$SOURCE_DIR" "s3://$AWS_S3_BUCKET/$DEST_DIR/$COMMIT_SHA/" --no-progress $ENDPOINT_ARGS "$@"

# Sync to 'latest' path (mirror current source, idempotent)
aws s3 sync "$SOURCE_DIR" "s3://$AWS_S3_BUCKET/$DEST_DIR/latest/" --no-progress --delete $ENDPOINT_ARGS "$@"