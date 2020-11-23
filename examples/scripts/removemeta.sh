#!/bin/bash

# Remove all META-INF files from JARS
# plus some specific class file

find springbootwildfly.war -name META-INF -type d | xargs rm -rf

rm -f springbootwildfly.war/WEB-INF/lib/jakarta.validation-api-2.0.1.jar/javax/validation/bootstrap/GenericBootstrap.class
