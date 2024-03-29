%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.11.0

-ifndef(protos).
-define(protos, true).

-define(protos_gpb_version, "4.11.0").

-ifndef('AUTHENTICATION_PB_H').
-define('AUTHENTICATION_PB_H', true).
-record('Authentication',
        {type                   :: 'REGISTER' | 'LOGIN' | integer(), % = 1, enum Authentication.AuthType
         userType               :: 'PRODUCER' | 'IMPORTER' | integer(), % = 2, enum Authentication.UserType
         username               :: iodata(),        % = 3
         password               :: iodata()         % = 4
        }).
-endif.

-ifndef('TRANSACTION_PB_H').
-define('TRANSACTION_PB_H', true).
-record('Transaction',
        {txn                    :: {produce, protos:'Produce'()} | {import, protos:'Import'()} | undefined % oneof
        }).
-endif.

-ifndef('PRODUCE_PB_H').
-define('PRODUCE_PB_H', true).
-record('Produce',
        {productName            :: iodata(),        % = 1
         producerName           :: iodata(),        % = 2
         minimumAmount          :: integer(),       % = 3, 32 bits
         maximumAmount          :: integer(),       % = 4, 32 bits
         minimumUnitaryPrice    :: integer(),       % = 5, 32 bits
         negotiationPeriod      :: integer()        % = 6, 32 bits
        }).
-endif.

-ifndef('IMPORT_PB_H').
-define('IMPORT_PB_H', true).
-record('Import',
        {productName            :: iodata(),        % = 1
         producerName           :: iodata(),        % = 2
         importerName           :: iodata(),        % = 3
         quantity               :: integer(),       % = 4, 32 bits
         unitaryPrice           :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('SERVERRESPONSE_PB_H').
-define('SERVERRESPONSE_PB_H', true).
-record('ServerResponse',
        {success                :: boolean() | 0 | 1 % = 1
        }).
-endif.

-ifndef('SALEINFO_PB_H').
-define('SALEINFO_PB_H', true).
-record('SaleInfo',
        {username               :: iodata(),        % = 1
         quantity               :: integer(),       % = 2, 32 bits
         price                  :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('RESPONSE_PB_H').
-define('RESPONSE_PB_H', true).
-record('Response',
        {res                    :: {importer, protos:'ImporterResponse'()} | {producer, protos:'DealerTimeout'()} | undefined % oneof
        }).
-endif.

-ifndef('IMPORTERRESPONSE_PB_H').
-define('IMPORTERRESPONSE_PB_H', true).
-record('ImporterResponse',
        {producerName           :: iodata(),        % = 1
         productName            :: iodata(),        % = 2
         quantity               :: integer(),       % = 3, 32 bits
         price                  :: integer()        % = 4, 32 bits
        }).
-endif.

-ifndef('DEALERTIMEOUT_PB_H').
-define('DEALERTIMEOUT_PB_H', true).
-record('DealerTimeout',
        {success                :: boolean() | 0 | 1, % = 1
         producerName           :: iodata(),        % = 2
         productName            :: iodata(),        % = 3
         sales = []             :: [protos:'SaleInfo'()] | undefined % = 4
        }).
-endif.

-ifndef('CATALOGREQUEST_PB_H').
-define('CATALOGREQUEST_PB_H', true).
-record('CatalogRequest',
        {request                :: {nn, protos:'POSTNegotiation'()} | {no, protos:'DELETENegotiation'()} | {gpi, protos:'GETProducerInfo'()} | {ge, protos:'GETEntities'()} | undefined % oneof
        }).
-endif.

-ifndef('POSTNEGOTIATION_PB_H').
-define('POSTNEGOTIATION_PB_H', true).
-record('POSTNegotiation',
        {productName            :: iodata(),        % = 1
         producerName           :: iodata(),        % = 2
         minimumAmount          :: integer(),       % = 3, 32 bits
         maximumAmount          :: integer(),       % = 4, 32 bits
         minimumUnitaryPrice    :: integer(),       % = 5, 32 bits
         negotiationPeriod      :: integer()        % = 6, 32 bits
        }).
-endif.

-ifndef('DELETENEGOTIATION_PB_H').
-define('DELETENEGOTIATION_PB_H', true).
-record('DELETENegotiation',
        {productName            :: iodata(),        % = 1
         producerName           :: iodata()         % = 2
        }).
-endif.

-ifndef('GETENTITIES_PB_H').
-define('GETENTITIES_PB_H', true).
-record('GETEntities',
        {'Entities'             :: 'PRODUCERS' | 'IMPORTERS' | integer() % = 1, enum GETEntities.Type
        }).
-endif.

-ifndef('GETENTITIESRESPONSE_PB_H').
-define('GETENTITIESRESPONSE_PB_H', true).
-record('GETEntitiesResponse',
        {entities = []          :: [iodata()] | undefined % = 1
        }).
-endif.

-ifndef('GETPRODUCERINFO_PB_H').
-define('GETPRODUCERINFO_PB_H', true).
-record('GETProducerInfo',
        {username               :: iodata(),        % = 1
         producerName           :: iodata()         % = 2
        }).
-endif.

-ifndef('GETPRODUCERINFORESPONSE_PB_H').
-define('GETPRODUCERINFORESPONSE_PB_H', true).
-record('GETProducerInfoResponse',
        {negotiations = []      :: [protos:'POSTNegotiation'()] | undefined % = 1
        }).
-endif.

-endif.
