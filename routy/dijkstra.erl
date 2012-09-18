-module(dijkstra).
-export([table/2, route/2]).
-import(lists).

entry(Node, Sorted) ->
	%Sorted is sorted on the distance =>
	%first occurs is the shortest way.
	case lists:keysearch(Node, 1, Sorted) of
		{value, {_,X,_}} ->
			X;
		false ->
			0
	end.

replace(Node, N, Gateway, Sorted) ->
	lists:merge(
		fun(A,B) -> {_,ALength,_}=A, {_,BLength,_} = B, ALength < BLength end,
		lists:keydelete(Node, 1, Sorted), 
		[{Node, N, Gateway}]).


update(Node,N,Gateway,Sorted) ->
	case entry(Node, Sorted) of
		0 ->
			Sorted;
		X ->
			case X > N of
				true ->
					replace(Node, N, Gateway, Sorted);
				false ->
					Sorted
			end
	end.

do_update([],_,_,Sorted) ->
	Sorted;
do_update([Head|TReachbl], Node, N, Sorted)->
	NewSorted = update(Head, N+1,Node, Sorted),
	do_update(TReachbl,Node,N,NewSorted).

iterate([],_,Table) ->
	Table;
iterate({_,inf,_},_,Table) ->
	Table;
iterate([{Node,N,Gateway}|Tail], Map, Table) ->
	Reachbl = map:reachable(Node, Map),
	NewTail = do_update(Reachbl,Node,N,Tail),
	iterate(NewTail,Map, [{Node,Gateway}|Table]).

build_sorted(_,[],Sorted) ->
	Sorted;
build_sorted(Gateway, [HNode|TNodes], Sorted)->
	case lists:member(HNode,Gateway) of
		true ->
			NewSorted = [{HNode,0,HNode}|Sorted];
		false ->
			NewSorted = [{HNode,inf,unknown}|Sorted]
	end,
	build_sorted(Gateway,TNodes,lists:keysort(2,NewSorted)).

table(Gateway,Map) ->
	Nodes = map:all_nodes(Map),
	Sorted = build_sorted(Gateway,Nodes,[]),
	iterate(Sorted, Map, []).

route(Node,Table) ->
	case lists:keysearch(Node, 1, Table) of
		{value, {_, Gateway}} ->
			{ok,Gateway};
		false ->
			notfound
	end.
