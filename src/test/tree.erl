-module(tree).
-export([
    empty/0,
    insert/3,
    lookup/2,
    has_value/2
]).

%%空树
empty() ->
	{node, 'nil'}.

%%插入结点
insert(Key, Val, {node, 'nil'}) ->
	{node, {Key, Val, {node, 'nil'}, {node, 'nil'}}};
%%插入左子树
insert(NewKey, NewVal, {node, {Key, Val, Smaller, Larger}}) when NewKey < Key ->
	{node, {Key, Val, insert(NewKey, NewVal, Smaller), Larger}};
%%插入右子树
insert(NewKey, NewVal, {node, {Key, Val, Smaller, Larger}}) when NewKey > Key ->
	{node, {Key, Val, Smaller, insert(NewKey, NewVal, Larger)}};
%%相等不做处理
insert(Key, Val, {node, {Key, _, Smaller, Larger}}) ->
	{node, {Key, Val, Smaller, Larger}}.

%%查找结点
lookup(_, {node, 'nil'}) ->
	undefined;
%%查找成功
lookup(Key, {node, {Key, Val, _, _}}) ->
	{ok, Val};
%%查找左子树
lookup(Key, {node, {NodeKey, _, Smaller, _}}) when Key < NodeKey ->
	lookup(Key, Smaller);
%%查找右子树
lookup(Key, {node, {_, _, _, Larger}}) ->
	lookup(Key, Larger).

% has_value(_, {node, 'nil'}) ->
% 	false;
% has_value(Val, {node, {_, Val, _, _}}) ->
% 	true;
% has_value(Val, {node, {_, _, Left, Right}}) ->
% 	case has_value(Val, Left) of
% 		true ->
% 			true;
% 		false ->
% 			has_value(Val, Right)
% 	end.
has_value(Val, Tree) ->
	try has_value1(Val, Tree) of
		false ->
			false
	catch
		true -> true
	end.
has_value1(_, {node, 'nil'}) ->
	false;
has_value1(Val, {node, {_, Val, _, _}}) ->
	throw(true);
has_value1(Val, {node, {_, _, Left, Right}}) ->
	has_value1(Val, Left),
	has_value1(Val, Right).




