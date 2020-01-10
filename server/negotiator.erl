-module[negotiator].

negotiator(Sock, Importers, Producers) ->
    receive
        {new_producer, Username, PID, Data} ->
            gen_tcp:send(Sock, Data),
            NewProducers = maps:put(ProducerName, PID, Producers),
            negotiator(Sock, Importers, NewProducers);
        {new_importer, Username, PID, Data} ->
            gen_tcp:send(Sock, Data),
            NewImporters = maps:put(Username, PID, Importers),
            negotiator(Sock, NewImporters, Producers);
        {tcp, _, Data} ->
            % decode data
            Map_Data = protos:decode_msg(Data, 'DealerTimeout'),
            % send info to producer
            {ok, ProducerName} = maps:find(producerName, Map_Data),
            {ok, Producer} = maps:find(ProducerName, Producers),
            Producer ! {timeout, negotiatorsHandler, Data},
            % extract importers' usernames, send them the producer's info and remove them from their map
            ImportersBuying = extractImporters([], maps:find(sales, Map_Data)),
            NewImporters = sendImporters(Importers, ImportersBuying, ProducerName),
            negotiator(Sock, NewImporters, Producers -- [ProducerName])
    end.

% Extracts importers' usernames from map
extractImporters(Importers, []) ->
    Importers.

extractImporters(Importers, [H|T]) ->
    MapImporter = protos:decode_msg(H, 'SaleInfo'),
    {ok, Username} = maps:find(username, Map_Importer),
    extractImporters(Importers ++ Username, T).

% Sends producer's username to each importer and extract them from importers' map
sendImporters(Importers, [], ProducerName) ->
    Importers.

sendImporters(Importers, [H|T], ProducerName) ->
    [PID ! {producer, negotiatorsHandler, ProducerName} || {ok, PID} <- maps:find(H, Importers)],
    sendImporters(Importers -- H, T).