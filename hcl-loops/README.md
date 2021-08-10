# Using Loops and Ansible tags to simplify Packer builds

**WORK IN PROGRESS**

This is an example and is missing some required values to keep the focus on the concept, not the execution. I may update this in the future to be a functional example.

## Description

An example of how you can use the new features of HCL2 support in Packer, along with Ansible tags, to create simple and maintainable Packer images for an organization.

This design is meant to scale to a large implementation. However, as the implementation grows, it may make sense to split the packer files or the core Ansible playbook into multiple files as the need arises. Keep in mind that major deviations from this design will reduce it's effectiveness, and should be carefully considered.
