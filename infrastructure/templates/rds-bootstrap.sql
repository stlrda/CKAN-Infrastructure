\set datastore_ro_password '\'' `echo $DATASTORE_READONLY_PASSWORD` '\''

CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD :datastore_ro_password;
CREATE DATABASE datastore OWNER ckan ENCODING 'utf-8';

CREATE DATABASE ckan_test OWNER ckan ENCODING 'utf-8';
CREATE DATABASE datastore_test OWNER ckan ENCODING 'utf-8';
