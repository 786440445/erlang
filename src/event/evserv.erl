%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 六月 2018 23:52
%%%-------------------------------------------------------------------
-module(evserv).
-include("common.hrl").

-record(state,     {events, clients}).
-record(event,     {name = "",
                    description = "",
                    pid,
                    timeout = {{1970, 1, 1}, {0, 0, 0}}
                    }).
%% API
-export([
    init/0,
    start/0,
    start_link/0,
    terminate/0
    ]).

-export([
    subscribe/1,
    add_event/3,
    cancel/1,
    listen/1
    ]).

%% 将事件列表和客户列表定义成有序字典
init() ->
    loop(#state{events = orddict:new(),
                clients = orddict:new()}).

start() ->
    register(?MODULE, Pid = spawn(?MODULE, init, [])),
    Pid.

start_link() ->
    register(?MODULE, Pid = spawn_link(?MODULE, init, [])),
    Pid.

loop(S = #state{}) ->
    receive
    %% deal the message between server and client
        %% subscribe
        {Pid, MsgRef, {subscribe, Client}} ->
            Ref = erlang:monitor(process, Client),
            NewClients = orddict:store(Ref, Client, S#state.clients),
            Pid ! {MsgRef, ok},
            loop(S#state{clients = NewClients});
        %% add event
        {Pid, MsgRef, {add, Name, Description, TimeOut}} ->
            io:format("TimeOut : ~p~n",[TimeOut]),
            case tool:valid_datetime(TimeOut) of
                ?true ->
                    EventPid = event:start_link(Name, TimeOut),
                    NewEvents = orddict:store(Name, #event{name = Name,
                                                            description = Description,
                                                            pid = EventPid,
                                                            timeout = TimeOut}),
                    Pid ! {MsgRef, ok},
                    loop(S#state{events = NewEvents});
                ?false ->
                    Pid ! {MsgRef, {error, bad_timeout}},
                    loop(S)
            end;
        %% cancal some event
        {Pid, MsgRef, {cancel, Name}} ->
            Events =
                case orddict:find(Name, S#state.events) of
                    {ok, E} ->
                        event:cancel(E#event.pid),
                        orddict:erase(Name, S#state.events);
                    error ->
                        S#state.events
                end,
            Pid ! {MsgRef, ok},
            loop(S#state{events = Events});

    %% deal the message between server and event
        {done, Name} ->
            case orddict:find(Name, S#state.events) of
                {ok, E} ->
                    send_to_client({done, E#event.name, E#event.description}, S#state.clients);
                error ->
                    loop(S)
            end;

        shutdown ->
            exit(shutdown);
        {'DOWN', Ref, process, _Pid, _Reason} ->
            loop(S#state{clients = orddict:erase(Ref, S#state.clients)});
        code_change ->
            ?MODULE:loop(S);
        Unknow ->
            io:format("Unknown message : ~p~n", [Unknow]),
            loop(S)
    end.

terminate() ->
    ?MODULE ! shutdown.

send_to_client(Msg, ClientDict) ->
    orddict:map(fun(_Ref, Pid) -> Pid ! Msg end, ClientDict).

%% -----------------------------------------External_interface-------------
subscribe(Pid) ->
    Ref = erlang:monitor(process, whereis(?MODULE)),
    ?MODULE ! {self(), Ref, {subscribe, Pid}},
    receive
        {Ref, ok} ->
            {ok, Ref};
        {'DOWN', Ref, process, _Pid, Reason} ->
            {error, Reason}
    after 5000 ->
        {error, timeout}
    end.

add_event(Name, Description, TimeOut) ->
    Ref = make_ref(),
    io:format("Name: ~p~n",[Name]),
    io:format("Description: ~p~n",[Description]),
    io:format("TimeOut: ~p~n",[TimeOut]),
    ?MODULE ! {self(), Ref, {add, Name, Description, TimeOut}},
    receive
        {Ref, Msg} ->
            Msg
    after 5000 ->
        {error, timeout}
    end.

cancel(Name) ->
    Ref = make_ref(),
    ?MODULE ! {self(), Ref, {cancel, Name}},
    receive
        {Ref, ok} ->
            ok
    after 5000 ->
        {error, timeout}
    end.

listen(Delay) ->
    receive
        M = {done, _Name, _Description} ->
            [M | listen(0)]
    after Delay * 1000 ->
        []
    end.

