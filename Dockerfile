# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:3.5

MAINTAINER Kyle Manna <kyle@kylemanna.com>

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "http://dl-4.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*


# INSTALLING dnsmsq for masking .local domain
RUN apk --no-cache add dnsmasq
EXPOSE 53 53/udp

RUN apk --no-cache add supervisor



# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp


ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

RUN mkdir -p /var/log/supervisor
COPY etc/supervisord.conf /etc/supervisord.conf

#CMD ["ovpn_run"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf" , "-n"]

