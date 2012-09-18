-module(test).
-export([bench/2, start/3]).
bench(Host, Port) ->
    Start = now(),
    run(100, Host, Port),
    Finish = now(),
    Duration = timer:now_diff(Finish, Start),
    io:format("request/s: ~p ~n",[100/(Duration/1000000)]).
run(N, Host, Port) ->
    if
	N == 0 ->
	    ok;
	true ->
	    request(Host, Port),
	    run(N-1, Host, Port)
    end.
request(Host, Port) ->
    Opt = [list, {active, false}, {reuseaddr, true}],
    {ok, Server} = gen_tcp:connect(Host, Port, Opt),
    gen_tcp:send(Server, http:get("foo")),
    Recv = gen_tcp:recv(Server, 0),
    case Recv of
	{ok, _} ->
	    ok;
	{error, Error} ->
	    io:format("test: error: ~w~n", [Error])
    end.

start(Host, Port, NbClient)->
    if 
	NbClient == 0 -> 
	    ok;
	true ->
	    spawn(test, bench, [Host, Port]),
	    start(Host, Port, NbClient-1)
    end.
	
