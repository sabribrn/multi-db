# README

This is just a dummy project that illustrates the basic setup needed for a multi-database and replicas configuration.  
Something that it's important to keep in mind is that multiple databases and reading replicas 
are two different features and they can be used separately or together.

## TL;DR
- We can have multiple databases and map each model to one of them
- We can also have a replica for each one of those DBs
- We can even have two different RDBMS
- We can manually switch between writer and replica to offload some heavy query to the replica
- Rails provides a switching feature but its assumption would probably fit only in a trivial app
- An update to Rails 6.1 will be necessary

## QUICK-START
```
git clone git@github.com:sabribrn/multi-db.git
cd multi-db
bundle install
bundle exec rails s
```
This project comes with four DBs included (two masters and two replicas).  
`Company` model is mapped to the primary DB while `Shipment` to the secondary DB.  
Four endpoints are defined and each one hits a different DB:
- GET companies/master
- GET companies/replica
- GET shipments/master
- GET shipments/replica  

Hit an endpoint and check the log to see which DB has been used.  
Example:
```
$ curl http://localhost:3000/shipments/replica

Started GET "/shipments/replica" for 127.0.0.1 at 2022-06-29 13:16:38 +0200
Processing by ShipmentsController#replica as */*
  Shipment Load (0.7ms)  SELECT "shipments".* FROM "shipments" <--- THIS QUERY HIT A REPLICA DB (secondary_replica.sqlite3)
  ↳ config/initializers/multi_db_logger.rb:7:in `log'
Completed 200 OK in 12ms (Views: 9.7ms | Allocations: 3817)
```


----

# FURTHER INFO

## DB SETUP
This project defines four DBs:
- primary
- primary_replica
- secondary
- secondary_replica  

The sqlite DBs have been included in the repo to simplify the clone and run.

## DB ROLES
The base `ActiveRecord` classes used are:
- `ApplicationRecord` with two roles:
  - `writing` mapped to the primary DB
  - `reading` mapped to the primary replica DB
- `SecondaryBase` with two roles:
  - `writing` mapped to the secondary DB
  - `reading` mapped to the secondary replica DB

## MODELS
If a class needs to be persisted into the secondary DB, it should extend `SecondaryBase` instead of `ApplicationRecord`.  
For example, `Shipment` is using the secondary DB
```
class Shipment < SecondaryBase
  belongs_to :company
end
```

## DB CONNECTION SWITCHING
### AUTOMATIC
Rails provides a mechanism to switch automatically from a master to its replica, based on the HTTP verb.  
In api-only apps this feature is disabled (although it can be enabled) but it's probably best to avoid using it because
of the assumption that a GET request will only make reading calls to the DB, something that is not always true.  
This assumption propagates to the gems used: if a gem tries to write to the DB during a GET request, Rails
will throw an `ActiveRecord::ReadOnlyError` and that means that the gem needs to be patched.

### MANUAL
Luckily there is another mechanism to manually choose which DB to use for a given block of code.  
This block will execute the query against the writing DB (better to say the DB with the role set to `writing`):
```
ActiveRecord::Base.connected_to(role: :writing) do
  Company.all
end
```
While this one will execute the query against the reading DB (the replica in this case):
```
ActiveRecord::Base.connected_to(role: :reading) do
  Company.all
end
```

With this feature we can offload heavy queries to a replica DB.  

For example, calling these methods (taken from `CompaniesController`)
```
companies_from_master_db
companies_from_replica_db
companies_from_master_db
```
Will results in these operations
```
Company Load (0.0ms)  SELECT "companies".* FROM "companies" <--- THIS QUERY HIT A MASTER DB (primary.sqlite3)
Company Load (0.0ms)  SELECT "companies".* FROM "companies" <--- THIS QUERY HIT A REPLICA DB (primary_replica.sqlite3)
Company Load (0.0ms)  SELECT "companies".* FROM "companies" <--- THIS QUERY HIT A MASTER DB (primary.sqlite3)
```



