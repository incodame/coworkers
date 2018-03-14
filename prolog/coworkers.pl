:- module(coworkers, [ask_wf_parameter/1, wf/2]).

%
% worfklow DSL
%

ask_wf_parameter(P) :-
    shift(ask_wf_parameter(P)).

task('sync git repo', [ParentRepoVersions]) :-
    writeln('{ Task } Synchronize Git Repo'),
    ask_wf_parameter(re(Repo)),
    ask_wf_parameter(br(Branch)),
    format(string(Message), 'syncing repo ~w branch ~w', [Repo, Branch]),
    % will call groovy template
    % Temp
    ParentRepoVersions = [repo_a_ve("1.0.7"),
                          repo_b_ve("3.3.5"),
                          repo_c_ve("2.0.11")],
    writeln(Message).

task('modify parent repo versions', [ParentRepoVersions]) :-
    writeln('{ Task } Modify Versions of Parent Git Repos'),
    writeln(ParentRepoVersions),
    % TODO - these properties come from the sync task as input 
    ask_wf_parameter(repo_a_ve(RepoAVersion)),
    ask_wf_parameter(repo_b_ve(RepoBVersion)),
    ask_wf_parameter(repo_c_ve(RepoCVersion)),
    format(string(Message), 'modifying versions = ~w, ~w, ~w', [RepoAVersion,
                                                                RepoBVersion,
                                                                RepoCVersion]),
    % will call groovy template
    writeln(Message).

input_parameter(PropsDl, Functor, UProps) :-
    functor(Functor, Name, 1),
    term_variables(Functor, [ ParameterValue ]),
    PropsDl = KnownProps-[],
    (member(Functor, KnownProps) ->
         format(string(Message), '~w = ~w', [Name, ParameterValue]),
         writeln(Message),
         UProps = L-L
    ;
         format(string(Message), 'Confirm ~w:', [Name]),
         writeln(Message),
         read(ParameterValue),
         NewProp = Functor,
         UProps  = [NewProp|L]-L
    ).

dialog('coordinator', PropsDl, Param, PropsDl2) :-
    input_parameter(PropsDl, Param, NewDl),
    append_dl(NewDl, PropsDl, PropsDl2).

%?- workflow('release_project', [ re('coworkers') ]).

workflow('release_project', Props) :-
    %trace,
    wf(

        props( Props ),

            % data exchange between tasks happens through variable unification

            node(dialog('coordinator'),
                       [ node(task('sync git repo', [ParentRepoVersions]), []),
                         node(task('modify parent repo versions', [ParentRepoVersions]), [])
                       ])

    ).

wf(props(Props), Tree) :-
    %trace,
    init_dl_from_list(Props, PropsDList),
    Tree = node(Koordinator, _), % find Koordinator
    activities(Tree, Queue-[]),
    do_tasks_seq(PropsDList, Queue, Koordinator).

activities([H|T], L1-L3) :-
    activities(H, L1-L2), activities(T, L2-L3), !.
activities(node(Act, Children), L1-L3) :-
    activities(Act, L1-L2), activities(Children, L2-L3), !.
activities(Act, [Act|L]-L) :- Act = task(_,_), !.
activities(_, L-L).

do_tasks_seq(_, [], _) :- !.
do_tasks_seq(PropsDl, [Act|T], Coordinator) :-
    %Act = task(ActIdent), % Coordinator/Controller gets called only when required
    %Act = task(_,_),
    reset(Act, Term1, Act1),
    ( Term1 = 0 ->
      PropsDl2 = PropsDl,
      RestActs = T
    ;
      Term1 = ask_wf_parameter(Param) ->
       %trace,
       call(Coordinator, PropsDl, Param, PropsDl2),
       [Param|_]-[] = PropsDl2,
       RestActs = [Act1|T]
    ),
    do_tasks_seq(PropsDl2, RestActs, Coordinator).

append_dl(A-B, B-C, A-C). 

init_dl_from_list([], L-L).
init_dl_from_list([H|T], Dlist) :-
    HDlist = [H|Z]-Z,
    init_dl_from_list(T, TDlist),
    append_dl(HDlist, TDlist, Dlist).
