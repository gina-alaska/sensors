GINA sensor data system
========
Ingestion, processing, and distribution.
--------

GINA's sensor data system can ingest data in a MongoDB database from CSV or other formated data files.  Once in the system the data can be processed to filter or modify the data and then this processed data is placed back into the database.  This processed data can then be used for graphing, download, or served out through API interfaces.

The system can be divided into several major components:

* Ingestion Scripts
* Processing Scripts
* Alert Scripts
* Maintenance Web Interface
* Public Web Interface
* Graphing Scripts
* Other Web-API/Product Scripts


## Ingestion Scripts
--------
These scripts take a formated sensor data file, parse it, do a little front-end processing, and then ingest the data into the MongoDB database. There are two default ingesting scripts, one for a JSON formated files and another for CSV formated files. Other formats are supportable, but the scripts must be custom written.  There are several helper functions to help with this task.

The ingestion scripts can be ran either externally from the web interface via a service or from within asynchronously. 

## Processing Scripts
--------
Processing scripts take the raw sensor data and then apply a processing chain to it, the results of which get ingested back into the database.  Several processing tools are available, for instance, mean/median filters, and data adjustment tools. The tools can use the R Project for Statistical Computing package or ruby to process the data. 

The scripts are ran asynchronously with in, or can be ran externally from the web interface to do automated processing of incoming data.

## Alert Scripts
--------
The alert scripts check the incoming data for predefined criteria and then alert the systems users if that criteria is matched.  Very similar to the processing chain, an alert chain can also be attached to a sensor data stream.  This alert chain is made up of one to many tools that check the incoming data.  The system's user can choose how the alert is handled once a match is made, by either sending email(s) or by generating an alert in the web interface, or both. 

Alerts can check for a sensor that is no longer communicating or can check for a particular event.

## Maintenance Web Interface
--------
This interface is used by the data provider to manage the sensor platform and any processing done on that data.  This Web tool provides interfaces to all of the major components of the GINA sensor system.  It also allows the user to view the raw and processed sensor data so they may be compared and adjusted. Graphs of the data can be constructed with the built in graphing language.  These graphs can then be served out via the public web interface.

## Public Web Interface
--------
This is the public face of the sensor system.  This face allows web sites and external users access to the sensor data through various interfaces. 

## Graphing Scripts
--------
These scripts generate graphs of the sensor data and are controlled through predefined templates.  Currently the system supports line, depth, and profile graphs.

## Other Web-API/Product scripts
--------
This is a catch-all category of scripts and tools that build products or give access to the sensor data.  
