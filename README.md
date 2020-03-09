# FPLA customised version of CCD Docker :whale: 

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [License](#license)

## Prerequisites

- [Docker](https://www.docker.com)

*Memory and CPU allocations may need to be increased for successful execution of ccd applications altogether*

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - minimum version 2.0.57 
- [jq Json Processor](https://stedolan.github.io/jq)

## Quick start
Login to the Azure Container registry:

```bash
./ccd login
```
Note:
if you experience any error with the above command, try `az login` first

Pulling latest Docker images:

```bash
./ccd compose pull
```

Creating and starting the containers:

```bash
./ccd compose up -d
```

Scripts to create FPLA test users and import FPLA CCD definitions are located in bin directory.

To add adoption service: 

```
 IDAM_ADMIN_USER=<enter email> IDAM_ADMIN_PASSWORD=<enter password> ./bin/add-services.sh
```

To add roles required to import ccd definition: 

```
 IDAM_ADMIN_USER=<enter email> IDAM_ADMIN_PASSWORD=<enter password> ./bin/add-roles.sh
```

To add users: 

```
./bin/add-users.sh
```

`IDAM_ADMIN_USER` and `IDAM_ADMIN_PASSWORD` details can be found on confluence.

To enable stubbing of the ```PROXY_PAYMENTS``` set the ```PROXY_PAYMENTS_STUB``` environment variable to the desired url. 

----

This project should aim to keep upto date with the [base CCD Docker project](https://github.com/hmcts/ccd-docker)

## LICENSE

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
