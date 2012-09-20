-module(test).
-export([start/0, stop/1, start/2]).

start() ->
	Log = logger:start([john, paul, ringo, george, michel, luc, louis, henry, lucas]),
	A = worker:start(john, Log, 13, 2000, 100),
	B = worker:start(paul, Log, 34,2000, 100),
	C = worker:start(ringo, Log, 45, 2000, 100),
	D = worker:start(george, Log, 19, 2000, 100),
	E = worker:start(michel, Log, 42, 2000, 100),
	F = worker:start(luc, Log, 31, 2000, 100),
	G = worker:start(louis, Log, 28, 2000, 100),
	H = worker:start(henry, Log, 12, 2000, 100),
    I = worker:start(lucas, Log, 40, 2000, 100),
	A ! {peers, [B, C, D, E, F, G, H, I]},
	B ! {peers, [A, C, D, E, F, G, H, I]},
	C ! {peers, [A, B, D, E, F, G, H, I]},
	D ! {peers, [A, B, C, E, F, G, H, I]},
	E ! {peers, [A, B, C, D, F, G, H, I]},
	F ! {peers, [A, B, C, E, D, G, H, I]},
	G ! {peers, [A, B, C, E, F, D, H, I]},
	H ! {peers, [A, B, C, E, F, G, D, I]},
	I ! {peers, [A, B, C, E, F, G, H, D]},
	[Log, A, B, C, D, E, F, G, H, I].

start_worker([],_,_,_,PidList) ->
    PidList;
start_worker([Name|Left], Log, Sleep, Jitter, PidList) ->
    P = worker:start(Name, Log,random:uniform(100), Sleep, Jitter),
    start_worker(Left, Log, Sleep, Jitter, [P|PidList]).

advertise_worker([], _) ->
    ok;
advertise_worker([A|Left], [Curr|Others]) ->
    A ! {peers, Others},
    advertise_worker(Left, Others ++ [Curr]).


start(Names, Seed) ->
    Log = logger:start(Names),
    random:seed(Seed, Seed, Seed),
    PidList = start_worker(Names, Log, 2000, 100, []),
    advertise_worker(PidList, PidList),
    [Log|PidList].

stop([])->
    ok;
stop([A|Left]) ->
    A ! stop,
    stop(Left).

