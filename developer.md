# Redmine Plugin Setup

1. Go to the `plugins/` Redmine directory,
1. Clone this repository,
1. Restart the app & enjoy.

# Update

When you update the VueJS App, run `rake redspot_build`.
Generated webpack files will be copied in their Redmine plugin directories.

For specific actions on the VueJS App, please look at [redspot_vuejs/README.md](redspot_vuejs/README.md)

# Theming

You can override many variables to customize you Redspot.
To watch and build the plugin run :
```
cd redspot_vuejs/
npm run dev
```

Open `redspot_vuejs/src/Redspot.vue` and override the Synbioz theme at the end of the file (SASS variables).

# Run locally outside of Redmine

There's a demo HTML file that's compiled with assets to be run out of redmine.
Run an http server like :

```
http-server . 
```

And go to [http://192.168.1.66:8080/redspot_vuejs/dist/](http://192.168.1.66:8080/redspot_vuejs/dist/)