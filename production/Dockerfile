FROM alpine

# Minimal requirements for production
RUN \
  # Upgrade Alpine and base packages
  apk --no-cache upgrade && \
  # Install Erlang/OTP deps
  apk add --no-cache \
    ncurses-dev \
    openssl-dev
