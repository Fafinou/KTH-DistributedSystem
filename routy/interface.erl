-module(intf).
-export([new/0, add/4,remove/2, lookup/2, ref/2, name/2, list/1, broadcast/2]).
-import(lists).

new() ->
	[].

add(Name, Ref, Pid, Intf) ->
	[{Name,Ref,Pid}|Intf].

remove(Name, Intf) ->
	lists:keydelete(Name, 1, Intf).

lookup(Name, Intf) ->
	case lists:keysearch(Name, 1, Intf) of
		{value, {_,_,Pid}} ->
			{ok, Pid};
		false ->
			notfound
	end.

ref(Name, Intf) ->
	case lists:keysearch(Name, 1, Intf) of
		{value, {_,Ref,_}} ->
			{ok, Ref};
		false ->
			notfound
	end.

name(Ref, Intf) ->
	case lists:keysearch(Ref, 2, Intf) of
		{value, {Name,_,_}} ->
			{ok, Name};
		false ->
			notfound
	end.

get_name({Name,_,_}, AccIn) ->
	[Name|AccIn].

list(Intf) ->
	lists:foldl(fun(T,AccIn) -> get_name(T, AccIn) end,[],Intf).


broadcast(Message, Intf) ->
	lists:foreach(fun({_,_,Pid}) ->
				Pid ! Message end,
			Intf).
