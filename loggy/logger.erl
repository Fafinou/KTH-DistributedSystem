-module(logger).
-export([start/1, stop/1]).

start(Nodes) ->
	spawn(fun() ->init(Nodes) end).

stop(Logger) ->
	Logger ! stop.

init_clocks([], Clocks) ->
    Clocks;
init_clocks([A|B], Clocks)->
    NewClocks = [{A, 1}|Clocks],
    init_clocks(B, NewClocks).


init(Nodes) ->
    Clocks = init_clocks(Nodes, []),
    loop(Clocks, [], 1).

drain_queue([], _ , {NewQueue, S}) ->
    {NewQueue,S};
drain_queue([{From, Time, Msg}|B], Stamp, {NewQueue, S}) ->
    if 
        Time < Stamp ->
            log(From, Time, Msg),
            drain_queue(B, Stamp, {NewQueue, S});
        true ->
            drain_queue(B, Stamp,{[{From, Time, Msg}|NewQueue], S+1})
    end.

min_list([], Min) ->
    Min;
min_list([{_,Val}|B],Min) ->
    if
        Val < Min ->
            min_list(B, Val);
        true ->
            min_list(B, Min)
    end.

loop(Clocks, Queue, CurrentStamp) ->
	receive
		{log, From, Time, Msg} ->
            if
                Time == CurrentStamp ->
                    log(From, Time, Msg),
                    loop(lists:keyreplace(From, 1, Clocks, {From, Time}), Queue, CurrentStamp);
                true ->
                    NewQueue = [{From, Time, Msg}| Queue],
                    NewClocks = lists:keyreplace(From, 1, Clocks, {From, Time}), 
                    NewStamp = min_list(NewClocks, inf),
                    if 
                        NewStamp > CurrentStamp ->
                            {NewNewQueue, Size} = drain_queue(lists:keysort(2,NewQueue), NewStamp, {[],0}),
                            io:format("size of queue: ~w ~n",[Size]),
                            loop(Clocks, NewNewQueue, NewStamp);
                        true ->
                            loop(NewClocks, NewQueue, NewStamp)
                    end

            end;

		stop ->
			ok
	end.

log(From, Time, Msg) ->
	io:format("log: ~w ~w ~p~n", [From, Time, Msg]).


