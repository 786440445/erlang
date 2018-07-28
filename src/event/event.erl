%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 六月 2018 23:52
%%%-------------------------------------------------------------------

-module(event).
-record(state,        {server, name="", time_out = 0}).
-include("common.hrl").

-export([
	init/3,
	start/2,
	start_link/2,
	cancel/1
	]).

start(EventName, Delay) ->
	spawn(?MODULE, init, [self(), EventName, Delay]).

start_link(EventName, Delay) ->
	spawn_link(?MODULE, init, [self(), EventName, Delay]).

init(Server, EventName, DateTime) ->
	loop(#state{server = Server, name = EventName, time_out = tool:time_to_go(DateTime)}).
	
loop(S = #state{server = Server, time_out = [T | Next]}) ->
	receive
		{Server, Ref, cancel} ->
			Server ! {Ref, ok}
	after T * 1000 ->
		case Next == [] of
			true ->
				Server ! {done, S#state.name};
		 	_ ->
		   		loop(S#state{time_out = Next})
		end
	end.

% ExternalInterface-----------------------
cancel(Pid) ->
	Ref = erlang:monitor(process, Pid),
	Pid ! {self(), Ref, cancel},
	receive
		{Ref, ok} ->
			erlang:demonitor(Ref, [flush]),
			ok;
		{'DOWN', Ref, process, Pid, _Reason} ->
			ok
	end.
