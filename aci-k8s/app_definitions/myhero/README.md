# MyHero
MyHero is a sample micro service application designed as a learning tool and experiment to explore cloud native applications and architecture.  Full details on the application can be found at [https://github.com/hpreston/myhero_demo](https://github.com/hpreston/myhero_demo)

## Deploying Application
Use the `kubectl` tool to `apply` each of the yaml files.  While order doesn't specifically matter, it is suggested to deploy them in this order (bottom-up).

1. myhero_data.yaml
2. myhero_mosca.yaml
3. myhero_ernst.yaml
4. myhero_app.yaml
5. myhero_ui.yaml  
