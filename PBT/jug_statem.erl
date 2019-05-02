-module(jug_statem).

-behaviour(proper_statem).

-include_lib("proper/include/proper.hrl").

-export([test/1]).

-export([big_to_small/0, empty_big/0, empty_small/0,
	 fill_big/0, fill_small/0, small_to_big/0]).

-export([command/1, initial_state/0, next_state/3,
	 postcondition/3, precondition/2]).

-record(state,
	{small  :: pos_integer(), big  :: pos_integer()}).

%%--------------------------------------------------------------------
%%% Statem callbacks
%%--------------------------------------------------------------------

test(N) ->
    proper:quickcheck((?MODULE):prop_never_four_litres(),
		      N).

prop_never_four_litres() ->
    ?FORALL(Cmds, (commands(?MODULE)),
	    (?TRAPEXIT(begin
			 {History, State, Result} = run_commands(?MODULE, Cmds),
			 ?WHENFAIL((io:format("History: ~w~nState: ~w\nResult: ~w~n",
					      [History, State, Result])),
				   (aggregate(command_names(Cmds),
					      Result =:= ok)))
		       end))).

initial_state() -> #state{small = 0, big = 0}.

command(_S) ->
    frequency([{1, {call, ?MODULE, fill_small, []}},
	       {1, {call, ?MODULE, fill_big, []}}]
		++
		[{1, {call, ?MODULE, empty_small, []}}] ++
		  [{1, {call, ?MODULE, empty_big, []}}] ++
		    [{1, {call, ?MODULE, big_to_small, []}}] ++
		      [{1, {call, ?MODULE, small_to_big, []}}]).

%%-----------------------------------------------------------------------------
%% Mock commands
%%-----------------------------------------------------------------------------

fill_small() -> ok.

fill_big() -> ok.

empty_small() -> ok.

empty_big() -> ok.

small_to_big() -> ok.

big_to_small() -> ok.

%%-----------------------------------------------------------------------------
%% Preconditions
%%-----------------------------------------------------------------------------

precondition(_, _) -> true.

%%-----------------------------------------------------------------------------
%% Transitions
%%-----------------------------------------------------------------------------

next_state(S, _V, {call, _, fill_small, []}) ->
    S#state{small = 3};
next_state(S, _V, {call, _, fill_big, []}) ->
    S#state{big = 5};
next_state(S, _V, {call, _, empty_small, []}) ->
    S#state{small = 0};
next_state(S, _V, {call, _, empty_big, []}) ->
    S#state{big = 0};
next_state(#state{small = Small, big = Big}, _V,
	   {call, _, small_to_big, []})
    when Small + Big =< 5 ->
    #state{small = 0, big = Small + Big};
next_state(#state{small = Small, big = Big}, _V,
	   {call, _, small_to_big, []}) ->
    #state{small = Small + Big - 5, big = 5};
next_state(#state{small = Small, big = Big}, _V,
	   {call, _, big_to_small, []})
    when Small + Big =< 3 ->
    #state{small = Small + Big, big = 0};
next_state(#state{small = Small, big = Big}, _V,
	   {call, _, big_to_small, []}) ->
    #state{small = 3, big = Small + Big - 3}.

%%-----------------------------------------------------------------------------
%% Postconditions
%%-----------------------------------------------------------------------------

postcondition(S, {call, _, small_to_big, []},
	      _Result) ->
    S#state.big =/= 4;
postcondition(S, {call, _, big_to_small, []},
	      _Result) ->
    S#state.big =/= 4;
postcondition(_, _, _) -> true.
