# Control Center (serviced) resource agents

This repository stores pacemaker resource agents used in Control Center

# Releasing

Use git flow to release a new version to the `master` branch.

The artifact version is defined in the [VERSION](./VERSION) file.

For Zenoss employees, the details on using git-flow to release a version is documented 
on the Zenoss Engineering 
[web site](https://sites.google.com/a/zenoss.com/engineering/home/faq/developer-patterns/using-git-flow).
After the git flow process is complete, a jenkins job can be triggered manually to build and 
publish the artifact. 
