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
    print/1
]).

print(X) ->
    io:format("~s :~p~n", [X, X]).