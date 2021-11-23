# Specs

The project specifications can be found in the specs directory. Use the directory to get an idea of the project capabilities and configuration.&#x20;

**Running Specs**

If you have all the requirements installed, running the specs should be fairly simple.** Run the following commands to run the specs locally**

```bash
shards build server
crystal specs
```

{% hint style="info" %}
Ensure you have a Postgres database process running with the correct credentials
{% endhint %}

Headless Mode

Specs run using the **Flux** shard, this allows for browser testing. Currently, the configuration is set to run `headless` by default, which means that you will not see the browser interactions, if you wish to change this behavior simply remove the \`-headless\` parameter for the `spec/flows` files&#x20;

```crystal
def initialize(@url : String, @username : String, @password : String)
  options = Marionette.firefox_options(args: ["-headless"])
  super(Marionette::Browser::Firefox, options)
end
```
