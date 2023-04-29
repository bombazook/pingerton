## Pingerton - ip address pinger

### Run api on host 9090
```
  docker-compose up -d
```
#### Api:
  - `POST /addresses?address=1.1.1.1`
  - `DELETE /addresses/1.1.1.1`
  - `GET /stats/1.1.1.1?from=2022-01-01+22%3A22%3A22.312+%2B06%3A00&to=2022-01-01+22%3A23%3A22.312+%2B06%3A00`

### Run pinger service
```
  docker-compose run --rm api sh -c 'bundle install && bundle exec bin/pingerton --debug'
```

### Run tests
```
  docker-compose run --rm api sh -c 'bundle install && bundle exec rspec spec'
```

### Known issues
- Pinger service doesn't work for external addresses in docker on mac
- Ipv6 not implemented
