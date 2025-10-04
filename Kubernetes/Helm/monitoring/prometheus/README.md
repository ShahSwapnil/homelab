# Overview

How to setup Prometheus Operator.

## Install CRDs and Operator

```bash
kubectl apply -f bundle.yaml --server-side
```

without the `--server-side` flag annotations are invalid error might be raised.
