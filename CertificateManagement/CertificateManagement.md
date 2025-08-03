# Certificate Management <!-- omit in toc -->

Documents the various scripts that accompany this markdown file.

- [Scripts](#scripts)
- [How to Create Certificates](#how-to-create-certificates)
- [References](#references)

## Scripts

`createHomeLabPKI.sh` creates the Root cert, Kubernetes CA and Certificate Manager CA using the other two scripts in the folder.
`createRootCertificate.sh` will create a Root CA Key and Certificate. it will also create a `.pfx` certificate bundle to install on a windows machine.
`createIntermediateCertificate.sh` will create an Intermediate CA signed by the Root CA.

## How to Create Certificates

If creating Public Key Infrastructure for HomeLab for the first time, execute the following command:

the script does have to be executed from the folder unless the folder path has been added $PATH environment variable.

```bash
./createHomeLabPKI.sh
```

Alternatively, if you just need to create an Intermediate CA Certificate

```bash
./createIntermediateCertificate.sh -n <IntermediateCAName>
```

On the off chance, a Root CA Certificate is needed

```bash
./createRootCertificate.sh
```

All scripts will checks for existence of files before creating them.

## References

[OpenSSL CA](https://openssl-ca.readthedocs.io/en/latest/introduction.html)
