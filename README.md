# Output when running ./poc.sh

apply the initial version of the CRD this contains an alpha, beta and a GA gate
```json
{
  "additionalProperties": true,
  "maxProperties": 20,
  "properties": {
    "featureA": {
      "description": "Feature A [Alpha since v1.21]",
      "nullable": true,
      "type": "boolean"
    },
    "featureB": {
      "default": true,
      "description": "Feature B [Beta since v1.21]",
      "nullable": true,
      "type": "boolean"
    },
    "featureC": {
      "default": true,
      "description": "Feature C [GA since v1.21]\nNote: This featureGate is deprecated and will be removed with v1.23. \nThis means the feature will be enabled permanently.\n",
      "nullable": true,
      "type": "boolean"
    },
    "featureD": {
      "description": "Feature D [Alpha since v1.21]",
      "nullable": true,
      "type": "boolean"
    }
  },
  "type": "object",
  "x-kubernetes-preserve-unknown-fields": true
}
```
then send our first CR which enables the alpha gate and still specifies the GA gate
let's have a look at the resulting CR
```json
{
  "featureA": true,
  "featureB": true,
  "featureC": true
}
```
as we see, all three gates are in there and true even the one not specified, only featureD does not show as it is alpha and not specified.
This is caused by the defaults we provide
now let's upgrade our CRD to the next release which removes the GA gate we deprecated
```json
{
  "additionalProperties": true,
  "maxProperties": 20,
  "properties": {
    "featureA": {
      "description": "Feature A [Alpha since v1.21]",
      "nullable": true,
      "type": "boolean"
    },
    "featureB": {
      "default": true,
      "description": "Feature B [Beta since v1.21]",
      "nullable": true,
      "type": "boolean"
    },
    "featureD": {
      "description": "Feature D [Alpha since v1.21]",
      "nullable": true,
      "type": "boolean"
    }
  },
  "type": "object",
  "x-kubernetes-preserve-unknown-fields": true
}
```
first let's check what gates are returned after the output should not have changed as we keep everything in the features field around
```json
{
  "featureA": true,
  "featureB": true,
  "featureC": true
}
```
now let's roll back that upgrade real quick and make sure all fields are still there
```json
{
  "featureA": true,
  "featureB": true,
  "featureC": true
}
```
and upgrade again, expectations confirmed, yay
now let us remove the removed GA field from our CR, this should also remove it from the live config in-cluster
```json
{
  "featureA": true,
  "featureB": true
}
```
should we downgrade now, everything should still be fine
```json
{
  "additionalProperties": true,
  "maxProperties": 20,
  "properties": {
    "featureA": {
      "description": "Feature A [Alpha since v1.21]",
      "nullable": true,
      "type": "boolean"
    },
    "featureB": {
      "default": true,
      "description": "Feature B [Beta since v1.21]",
      "nullable": true,
      "type": "boolean"
    },
    "featureC": {
      "default": true,
      "description": "Feature C [GA since v1.21]\nNote: This featureGate is deprecated and will be removed with v1.23. \nThis means the feature will be enabled permanently.\n",
      "nullable": true,
      "type": "boolean"
    },
    "featureD": {
      "description": "Feature D [Alpha since v1.21]",
      "nullable": true,
      "type": "boolean"
    }
  },
  "type": "object",
  "x-kubernetes-preserve-unknown-fields": true
}
```
```json
{
  "featureA": true,
  "featureB": true,
  "featureC": true
}
```
cleanup
customresourcedefinition.apiextensions.k8s.io "featuregates.poc.kubevirt.io" deleted
