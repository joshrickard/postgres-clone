[![Build Status](https://travis-ci.org/joshrickard/postgres-clone.svg?branch=master)](https://travis-ci.org/joshrickard/postgres-clone)

# PostgresClone

A command line utility for cloning Postgres databases.


## Installation

```ruby
gem install postgres-clone
```


## Usage

After installing the `postgres-clone` gem, you will have access to the `pg-clone` command which facilitates copying Postgres databases.

`pg-clone` will ssh into the remote server, perform a `pg_dump`, copy the dump to the target server, and then perform a `pg_restore`.


### Options

TODO:


### Examples

**Remote to Local**

```
# Dump remote database and restore to local Postgres server
pg-clone --src-host=db.example.com --src-db=database --dst-host=localhost
```

**Remote to Remote**

```
# Dump remote database and restore to a different remote Postgres server
pg-clone --src-host=db1.example.com --src-db=database --dst-host=db2.example.com
```

**Local to Local**

```
# Duplicate local Postgres database
pg-clone --src-host=local --src-db=database --dst-host=localhost
```

**Local to Remote**

```
# Dump local database and restore to a remote database server
pg-clone --src-host=local --src-db=database --dst-host=db.example.com
```


## TODOS

* Test keyless runs
* Clean up database dumps?
* Add checks for existing databases
* Add options for all prompts
* Check for existing dump on target machines before doing work

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshrickard/postgres-clone.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
