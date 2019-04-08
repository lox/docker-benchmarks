FROM alpine:3.8
ARG SIZE
RUN dd if=/dev/urandom of=outputfile.out bs=1024k count=$SIZE
RUN ls -lah outputfile.out
