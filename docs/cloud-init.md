# Why We Don’t Use Cloud-Init

- Not all cloud providers support Cloud-Init — for example, AWS Lightsail doesn’t, so it’s hard to rely on it everywhere.
- The size of the user data you can pass to Cloud-Init is often limited, which means you can’t do everything you might want during initialization.

Because of this, we use `remote-exec` instead. This lets us run scripts directly on the servers over SSH after they’re up and running. It gives us more control and flexibility, plus it’s usually easier to debug when things don’t go as planned.

Cloud-Init can be great when it’s fully supported, but for our needs, consistency and reliability across different clouds are more important.
