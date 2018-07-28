-module(server).
-export([loop/0,start/0]).

loop() ->
	receive 
		android ->
			apple;
		apple ->
			android
	end.

start() ->
	Pid = spawn(fun() ->loop() end),
	{Pid ! android, Pid ! apple}.