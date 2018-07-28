%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2018 1:09
%%%-------------------------------------------------------------------
-module(my_server).
-author("Administrator").

%% API
-export([call/2, cast/2, reply/2]).
-export([start/2, start_link/2]).

start(Module, State) ->
    spawn(fun() ->init(Module, State) end).
start_link(Module, State) ->
    spawn_link(fun() ->init(Module, State) end).


call(Pid, Msg) ->
    Ref = erlang:monitor(process, Pid),
    Pid ! {sync, self(), Ref, Msg},
    receive
        {Ref, Reply} ->
            erlang:demonitor(Ref, [flush]),
            Reply;
        {'DOWN', Ref, process, Pid, Reason} ->
            erlang:error(Reason)
    after 5000 ->
        erlang:error(timeout)
    end.

cast(Pid, Msg) ->
    Pid ! {async, Msg}.

reply({Pid, Ref}, Reply) ->
    Pid ! {Ref, Reply}.

%% ----------私有函数-----------

init(Module, State) ->
    loop(Module, Module:init(State)).

loop(Module, State) ->
    receive
        {async, Msg} ->
            loop(Module, Module:handle_cast(Msg, State));
        {sync, Pid, Ref, Msg} ->
            loop(Module, Module:handle_call(Msg, {Pid, Ref}, State))
    end.
