#!/bin/bash

# Remove all META-INF files from JARS
# plus some specific class file

find springbootwildfly.war -name META-INF -type d | xargs rm -rf

rm -f springbootwildfly.war/WEB-INF/lib/jakarta.annotation-api-1.3.5.jar/javax/annotation/PostConstruct.class
