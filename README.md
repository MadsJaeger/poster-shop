# PosterShop

A simple example application for purchasing your posters.

## Installation

Requires `ruby 3.12` and `rails ~> 7.0.3`, andtall dependencises with:

```shell
$ bundle install
```

## Database

Ensure to have a PostgreSQL server running, and configure `config/database.yml` if necesary. Create and migrate development and test databases:

```shell
$ rails db:migrate:reset
$ rails db:migrate RAILS_ENV=test
```

## Specing

A wide array of tests expects two users to exists: an admin and a guest. They are found in `db/seeds.rb`. Ensure to have test data seede before specing:

```shell
$ rails db:seed RAILS_ENV=test
```

Now win specs from the root folder:

```shell
$ bundle exec rspec
```

## Authentication

Authentication is implemented using `warden` creating two strategies: `:pwd` and `:jwt`. The former is is a password email authentication applied under `authentication#sign_in` which upon success isses a JWT to be placed in the `Authorization` header. All resources, except authentication, is protected with the `:jwt` strategy decoding and confirming issuance by the JTI whitelist strategy from stored `jtis`. Encryption and decryption uses the `ENV['JWT_SECRET']` which should be kept secert on a persisted volume. 

Under specs the controller wide `authenticate!` has not been mocked, rather provides the `spec/auth_helpers.rb` a token creation procedure which allows the developer to place the token in the `Authorixation` header before any request.