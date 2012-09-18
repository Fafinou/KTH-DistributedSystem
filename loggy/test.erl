-module(test).
-export([start/0, stop/1]).

start() ->
	Log = logger:start([john, paul, ringo, george]),
	A = worker:start(john, Log, 13, 2000, 10000),
	B = worker:start(paul, Log, 34,2000, 10000),
	C = worker:start(ringo, Log, 45, 2000, 10000),
	D = worker:start(george, Log, 19, 2000, 10000),
	A ! {peers, [B, C, D]},
	B ! {peers, [A, C, D]},
	C ! {peers, [A, B, D]},
	D ! {peers, [A, B, C]},
	[Log, A, B, C, D].

stop([Log, A, B, C, D]) ->
	Log ! stop,
	A ! stop,
	B ! stop,
	C ! stop,
	D ! stop.

