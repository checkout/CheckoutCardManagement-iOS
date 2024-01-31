#!/bin/bash

sonar-scanner \
    -Dsonar.organization=checkout-ltd \
    -Dsonar.projectKey=checkout_CheckoutCardManagement-iOS \
    -Dsonar.sources=. \
    -Dsonar.host.url=https://sonarcloud.io \
    -Dsonar.cfamily.build-wrapper-output.bypass=true \
    -Dsonar.c.file.suffixes=- \
    -Dsonar.cpp.file.suffixes=- \
    -Dsonar.objc.file.suffixes=-
