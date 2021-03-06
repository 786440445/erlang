%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2018 0:34
%%%-------------------------------------------------------------------
-module(kitty_server).
-include("common.hrl").
%% API
-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).

-record(cat, {name, color = green, description}).

%% 客户API
start_link() ->
    spawn_link(fun init/0).

%% 同步调用(没有返回值  类似cst)
order_cat(Pid, Name, Color, Description) ->
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, {order, Name, Color, Description}},
    receive
        {Ref, Cat} ->
            erlang:demonitor(Ref, [flush]),
            Cat;
        {'DOWN', Ref, process, Pid, Reason} ->
            erlang:error(Reason)
    after 5000 ->
        erlang:error(timeout)
    end.

%% 异步调用
return_cat(Pid, Cat = #cat{}) ->
    Pid ! {return, Cat},
    ok.

close_shop(Pid) ->
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, terminate},
    receive
        {Ref, ok} ->
            erlang:demonitor(Ref, [flush]),
            ok;
        {'DOWN', Ref, process, Pid, Reason} ->
            erlang:error(Reason)
    after 5000 ->
        erlang:error(timeout)
    end.


%% ------------服务器函数-------------
init() ->
    loop([]).

loop(Cats) ->
    receive
        {Pid, Ref, {order, Name, Color, Description}} ->
            case Cats =:= [] of
                ?true ->
                    Pid ! {Ref, make_cat(Name, Color, Description)},
                    loop(Cats);
                ?false ->
                    Pid ! {Ref, hd(Cats)},
                    loop(tl(Cats))
            end;
        {return, Cat = #cat{}} ->
            loop([Cat | Cats]);
        {Pid, Ref, terminate} ->
            Pid ! {Ref, r},
            terminate(Cats);
        Unknown ->
            tool:print(Unknown),
            loop(Cats)
    end.

%% -----------私有函数--------------
make_cat(Name, Color, Description) ->
    #cat{name = Name, color = Color, description = Description}.

terminate(Cats) ->
    [io:format("~p was set free.~n", [C#cat.name]) || C <- Cats].
