#!/usr/bin/env bash
brew install gomplate terraform jq vault
wget https://github.com/sigoden/argc/releases/download/v0.13.0/argc-v0.13.0-aarch64-apple-darwin.tar.gz
tar xzvf argc-v0.13.0-aarch64-apple-darwin.tar.gz
sudo mv argc /usr/local/bin
rm argc-v0.13.0-aarch64-apple-darwin.tar.gz