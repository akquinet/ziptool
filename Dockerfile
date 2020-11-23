FROM alpine:latest

ENV CONFIG_DIR="/tmp/ziptool"
ENV PATTERN_FILE="$CONFIG_DIR/patterns.txt"
ENV INPUT_DIR="$CONFIG_DIR/input"
ENV WORK_DIR="$CONFIG_DIR/work"
ENV TMP_DIR="$CONFIG_DIR/tmp"
ENV SCRIPT_DIR="$CONFIG_DIR/scripts"
ENV OUTPUT_DIR="$CONFIG_DIR/output"

RUN mkdir -p $INPUT_DIR $WORK_DIR $TMP_DIR $SCRIPT_DIR $OUTPUT_DIR
RUN apk add bash unzip

ADD ziptool.sh /
RUN chmod 755 /ziptool.sh

VOLUME /tmp/ziptool

ENTRYPOINT ["/ziptool.sh"]
