%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2018 0:52
%%%-------------------------------------------------------------------
-module(tool).
-author("Administrator").

%% API
-export([
    print/1,
    for/3
]).

print(X) ->
    io:format("~s :~p~n", [X, X]).

for(Max, Max, Fun) ->
    Fun(Max);

for(Min, Max, Fun) ->
    Fun(Min + 1),
    for(Min + 1, Max, Fun).
