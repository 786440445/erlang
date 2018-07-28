%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2018 1:14
%%%-------------------------------------------------------------------
-module(kitty_server2).
-include("common.hrl").

-record(cat, {name, color = green, description}).

%% API
-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-export([init/1, handle_call/3, handle_cast/2]).

%% 客户API
start_link() ->
    my_server:start_link(?MODULE, []).

%% 同步调用
order_cat(Pid, Name, Color, Description) ->
    my_server:call(Pid, {order, Name, Color, Description}).

%% 异步调用
return_cat(Pid, Cat = #cat{}) ->
    Pid ! {return, Cat},
    ok.
%% 同步调用
close_shop(Pid) ->
    my_server:call(Pid, terminate).

%%-----------------------服务器函数-----------------
init([]) ->
    [].

handle_call({order, Name, Color, Description}, From, Cats) ->
    case Cats =:= [] of
        ?true ->
            my_server:reply(From, make_cat(Name, Color, Description)),
            Cats;
        ?false ->
            my_server:reply(From, hd(Cats)),
            tl(Cats)
    end;
handle_call(terminate, From, Cats) ->
    my_server:reply(From, ok),
    terminate(Cats).

handle_cast({rrturn, Cat = #cat{}}, Cats) ->
    [Cat | Cats].

%% -----------------------私有函数--------------
make_cat(Name, Color, Description) ->
    #cat{name = Name, color = Color, description = Description}.

terminate(Cats) ->
    [io:format("~p was set free.~n", [C#cat.name]) || C <- Cats],
    exit(normal).