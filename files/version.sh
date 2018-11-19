#!/bin/bash
CURRENT_VERSION=$(head -n 1 VERSION)

if [ -z "$CURRENT_VERSION" ]; then
    printf "1.0.0" > VERSION
    exit 0
fi

MINOR_VERSION=$(printf ${CURRENT_VERSION} | tail -c 1)
NEXT_MINOR=$((${MINOR_VERSION} + 1))
NEXT_VERSION=$(printf "${CURRENT_VERSION%?}${NEXT_MINOR}")

echo ${CURRENT_VERSION}
echo ${MINOR_VERSION}

printf ${NEXT_VERSION} > VERSION