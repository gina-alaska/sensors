GINA sensor data system
========
Ingestion, processing, and distribution.
--------

GINA's sensor data system can ingest data in a MongoDB database from CSV or other formated data files.  Once in the system the data can be processed to filter or modify the data and then this processed data is placed back into the database.  This processed data can then be used for graphing, download, or served out through API interfaces.

The system can be divided into several major components:

* Ingestion Scripts
* Processing Scripts
* Alert Scripts
* Maintanence Web Interface
* Public Web Interface
* Graphing Scripts
* Other Web-API/Product Scripts


## Ingestion Scripts
--------
These scripts take a formated sensor data file, parse it, a little front-end processing, and then ingest the data into the MongoDB database. 