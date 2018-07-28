%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 六月 2018 1:14
%%%-------------------------------------------------------------------
-module(tool).
-author("Administrator").

-include("common.hrl").

%% API
-export([
    normalize/1,
    time_to_go/1,
    valid_datetime/1,
    test/0
]).

normalize(N) ->
    [N rem ?LIMIT | lists:duplicate(N div ?LIMIT, ?LIMIT)].

time_to_go(TimeOut = {{_, _, _}, {_, _, _}}) ->
    NowTime = calendar:local_time(),
    ToGo = calendar:datetime_to_gregorian_seconds(TimeOut)
        - calendar:datetime_to_gregorian_seconds(NowTime),
    Secs =
        case ToGo > 0 of
           ?true ->
               ToGo;
           _ ->
               0
       end,
    normalize(Secs).

valid_datetime({Date, Time}) ->
    try
        calendar:valid_date(Date) andalso valid_time(Time)
    catch
        error:function  ->
            ?false
    end;
valid_datetime(_) ->
    ?false.

valid_time({H, M, S}) ->
    valid_time(H, M, S).

valid_time(H, M, S) when H >= 0, H =< 24, M >= 0, M <60, S >=0, S < 60 ->
    ?true;
valid_time(_, _, _) ->
    ?false.

test() ->
    io:format("success~n").
