# State Passphrase

The state passphrase is used to encrypt and protect your local OpenTofu state file. It **must be at least 16 characters long** and you should **remember it well**, as losing this passphrase can make it impossible to access or manage your infrastructure.

To avoid typing the passphrase every time you run `./algo`, you can set it consistently using the environment variable `TF_VAR_state_passphrase`.
