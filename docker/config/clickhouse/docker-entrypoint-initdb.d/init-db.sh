#!/bin/bash
set -e
clickhouse client -n <<-EOSQL
  CREATE DATABASE IF NOT EXISTS ping_prod;
  CREATE DATABASE IF NOT EXISTS ping_test;
  CREATE TABLE IF NOT EXISTS ping_prod.ipv4pings (
    ip IPv4 NOT NULL,
    ping DateTime64(3) NOT NULL,
    pong DateTime64(3) NOT NULL,
    duration Decimal64(3) NOT NULL,
    timeout Bool NOT NULL DEFAULT false
  )
  ENGINE = MergeTree
  PRIMARY KEY (ip, ping);
  CREATE TABLE IF NOT EXISTS ping_prod.ipv6pings (
    ip IPv6 NOT NULL,
    ping DateTime64(3) NOT NULL,
    pong DateTime64(3) NOT NULL,
    duration Decimal64(3) NOT NULL,
    timeout Bool NOT NULL DEFAULT false
  )
  ENGINE = MergeTree
  PRIMARY KEY (ip, ping);
  CREATE DATABASE IF NOT EXISTS ping_test;
  CREATE TABLE IF NOT EXISTS ping_test.ipv4pings (
    ip IPv4 NOT NULL,
    ping DateTime64(3) NOT NULL,
    pong DateTime64(3) NOT NULL,
    duration Decimal64(3) NOT NULL,
    timeout Bool NOT NULL DEFAULT false
  )
  ENGINE = MergeTree
  PRIMARY KEY (ip, ping);
  CREATE TABLE IF NOT EXISTS ping_test.ipv6pings (
    ip IPv6 NOT NULL,
    ping DateTime64(3) NOT NULL,
    pong DateTime64(3) NOT NULL,
    duration Decimal64(3) NOT NULL,
    timeout Bool NOT NULL DEFAULT false
  )
  ENGINE = MergeTree
  PRIMARY KEY (ip, ping);
EOSQL
