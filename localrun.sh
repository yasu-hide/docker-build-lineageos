#!/bin/bash
BRANCH_NAME=lineage-16.0
LOCAL_DISTCC_HOSTS=""
LOCAL_DISTCC_POTENTIAL_HOSTS=""
DOCKER_ADD_HOSTS=""
DOCKER_PREFIX_HOSTS="host-%02d"
host_cnt=0
for h in $DISTCC_HOSTS;do
    hname=$(printf "$DOCKER_PREFIX_HOSTS" $host_cnt)
    DOCKER_ADD_HOSTS="--add-host=${hname}:${h:1:-1} $DOCKER_ADD_HOSTS"
    LOCAL_DISTCC_HOSTS="${hname} ${LOCAL_DISTCC_HOSTS}"
    LOCAL_DISTCC_POTENTIAL_HOSTS="${hname},cpp ${LOCAL_DISTCC_POTENTIAL_HOSTS}"
    host_cnt=$((host_cnt+1))
done
docker run --rm \
    -e BRANCH_NAME="$BRANCH_NAME" \
    -e DISTCC_HOSTS="$LOCAL_DISTCC_HOSTS" \
    -e DISTCC_POTENTIAL_HOSTS="$LOCAL_DISTCC_POTENTIAL_HOSTS" \
    -e USE_GOMA=$USE_GOMA -e USE_CCACHE=$USE_CCACHE \
    -v /build/ccache:/lineage/ccache \
    -v /build/src:/lineage/src \
    -v /build/out:/lineage/out \
    -v $(pwd)/local_manifests:/lineage/src/.repo/local_manifests \
    ${DOCKER_ADD_HOSTS} \
    --ulimit nproc=32768  --ulimit nofile=1048576 \
    --user root \
    vet5lqplpecmpnqb/docker-build-lineageos $*
