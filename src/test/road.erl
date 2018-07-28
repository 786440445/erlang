-module(road).
-export([
    main/0
]).

main() ->
	File = "road.txt",
	{ok, Bin} = file:read_file(File),
	parse_map(Bin).

% 转换成整形列表
parse_map(Bin) when is_binary(Bin) ->
	parse_map(binary_to_list(Bin));
parse_map(Str) when is_list(Str) ->
	Values = [list_to_integer(X) || X <- string:tokens(Str, "\r\n\t ")],
	group_vals(Values, []).

% 组成三元列表
group_vals([], Acc) ->
	lists:reverse(Acc);
group_vals([A, B, X|Rest], Acc) ->
	group_vals(Rest, [{A, B, X} | Acc]).

