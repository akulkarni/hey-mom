# Getting Started

## Gems

Before you start, make sure you run `bundle install` to install any missing Gems.

## Environment variables

Set the following local variables.

For example, on `bash`:

    export TWILIO_ACCOUNT_SID=(get from ajay)
    export TWILIO_AUTH_TOKEN=(get from ajay)
    export HEYMOM_HOST='http://callmom.herokuapp.com'


## Set up local database access

_Note that currently only Postgres is supported_

Create a copy of `config/database.example.yml` named `config/database.yml` and add the right settings for your local db.

For example, 

    development: &development
      adapter: postgresql
      database: heymom_dev
      username: [username]
      password: [password]
      host: localhost
      min_messages: warning

    test: &test
      <<: *development
      database: heymom_test


## Create a user with your test phone number

_Note that only US phone numbers are supported for now._

Send at HTTP POST request to `/register`.

For example:
    curl -d "" "http://127.0.0.1:5000/register?name=ajay&phone_number=19175551212&contact_name=mom&contact_phone_number=19736661313"


## Running locally

   foreman start -f Procfile-dev

