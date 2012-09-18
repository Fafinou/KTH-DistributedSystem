-module(map).
-export([new/0, update/3, reachable/2, all_nodes/1]).
-import(lists).
new() ->
	[].

update(Node, Links, Map) ->
	Map = lists:keydelete(Node, 1, Map),
	[{Node, Links}|Map].

reachable(Node, Map) ->
	case lists:keysearch(Node, 1, Map) of
		{value, {_, Links}} ->
			Links;
		false ->
			[]
	end.

extract_out(T, AccIn) ->
	{Node, List} = T,
	NewList = [Node|List],
	[NewList|AccIn].

merge_list([],C) ->
	C;
merge_list([A|B], C) ->
	NewC = lists:umerge(C,A),
	merge_list(B,NewC).

all_nodes(Map) ->
	List = lists:foldl(fun(T, AccIn) -> {N,L} = T, NL = [N|L], [NL|AccIn] end, [], Map),
	lists:usort(merge_list(List,[])).



