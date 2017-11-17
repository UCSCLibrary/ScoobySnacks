# configuration example 2

This example is more complex. The user incorporates two shared metadata profiles and extensive local customizations. The different sections of the metadata schema are broken up into different files to make it easier to find things.

As usual, the metadata.yml file is the only one that is automatically loaded. This file explicitly lists which other files to load and in which order. The shared schema files are loaded first. Local customizations are loaded afterward, overwriting shared settings where appropriate. 


# DISCLAIMER: NOT AN ACTUAL SCHEMA

This is an example of how one might specify a metadata schema using ScoobySnacks. It does not reflect any schema that UCSC has ever used or planned to use. Our developer made this up to demonstrate how the schema configuration files might work.