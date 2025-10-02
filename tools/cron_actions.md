# Place these to trigget the actions upon cron

```
#!/bin/bash -e

# Github actions token
export PAT=xxxx

## Each cu

curl -X POST   
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${PAT}" \
    https://api.github.com/repos/ellakcy/moodle-on-docker/actions/workflows/deploy-alpine-fpm.yml/dispatches \
    -d '{"ref":"master"}'
```

```
#!/bin/bash -e

# Github actions token
export PAT=xxxx
curl -X POST   
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${PAT}" \
    https://api.github.com/repos/ellakcy/moodle-on-docker/actions/workflows/deploy-fpm.yml/dispatches \
    -d '{"ref":"master"}'
```

```
#!/bin/bash -e

# Github actions token
export PAT=xxxx
curl -X POST   
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${PAT}" \
    https://api.github.com/repos/ellakcy/moodle-on-docker/actions/workflows/deploy-apache.yml/dispatches \
    -d '{"ref":"master"}'

```