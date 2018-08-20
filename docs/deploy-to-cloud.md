### Deploy with the wrapper
There are 2 ways of deployment via the wrapper script `./algo`

1. Run `./algo` and answer all the questions
2. You can define the required environment variables and run the wrapper `./algo apply` without answering the prompts. Replace the values according to your needs.
####
```
export ALGO_PROVIDER=digitalocean
export ALGO_REGION=ams3
export ALGO_SERVER_NAME=algo.local
export DIGITALOCEAN_TOKEN=XXX
```

Check [Cloud Specific Variables](cloud-specific-variables.md) for more information about variables supported.
