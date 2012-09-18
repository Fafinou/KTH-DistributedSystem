-module(pingpong).
-export([ping/2,pong/0,start_ping/0,start_pong/0]).
ping(0, Pong_Node) ->
    {pong,Pong_Node} ! finished,
    io:format("ping finished ~n");

ping(N, Pong_Node) -> 
    {pong, Pong_Node} ! {pid, self()},
    receive
	{pid, _} -> io:format("ping received pong ~n")    
    end,
    ping(N-1,Pong_Node).
pong() ->
    receive
	finished -> io:format("pong finished ~n");
	{pid, Ping_Pid} -> io:format("pong received ping ~n"),
		    Ping_Pid ! {pid, self()},
		    pong()
    end.
start_pong()->   
    register(pong,spawn(pingpong,pong,[])).

start_ping()->
    spawn(pingpong, ping, [5,'pong_@213.103.198.151']).
