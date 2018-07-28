%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2018 1:53
%%%-------------------------------------------------------------------
-module(kitty_gen_server).
-include("common.hrl").
-behavior(gen_server).

-record(cat, {name, color = green, description}).
%% API
-export([
    init/1,
    start_link/0,
    order_cat/4,
    return/2,
    close_stop/1]).

-export([
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    code_change/3,
    terminate/2
    ]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

%% 同步调用
order_cat(Pid, Name, Color, Description) ->
    gen_server:call(Pid, {order, Name, Color, Description}).

%% 异步调用
return(Pid, Cat = #cat{}) ->
    gen_server:cast(Pid, {return, Cat}).

%% 同步调用
close_stop(Pid) ->
    gen_server:call(Pid, terminate).

%% ------------------------------------------------------
init([]) ->
    {ok, []}.

handle_call({order, Name, Color, Description}, _From, Cats) ->
    case Cats =:= [] of
        ?true ->
            {reply, make_cat(Name, Color, Description), Cats};
        ?false ->
            {reply, hd(Cats), tl(Cats)}
    end;
handle_call(terminate, _From, Cats) ->
    {stop, normal, ok, Cats}.

handle_cast({return, Cat = #cat{}}, Cats) ->
    {noreply, [Cat | Cats]}.

handle_info(Msg, Cats) ->
    tool:print(Msg),
    {noreply, Cats}.

terminate(normal, Cats) ->
    [io:format("~p was set free.~n", [C#cat.name]) || C <- Cats],
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

make_cat(Name, Color, Description) ->
    #cat{name = Name, color = Color, description = Description}.