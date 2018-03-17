:- use_module(library(plunit)).
:- begin_tests(coworkers_wf).
:- use_module(library(coworkers)).

% wf_input_parameter

test(wf_input_parameter_input, []) :-
    wf_input_parameter([re('coworkers')|Z]-Z, ve(Version), ParameterDList-[]),
    ground(Version),
    ground(ParameterDList),
    length(ParameterDList, 1).

test(wf_input_parameter_noinput, []) :-
    wf_input_parameter([ve('1.3.2'), re('coworkers')|Z]-Z, re(Repo), ParameterDList-[]),
    ground(Repo),
    ground(ParameterDList),
    length(ParameterDList, 0).

append_dl(A-B, B-C, A-C).

test(wf_input_parameter_combined, []) :-
    PropsDl = [re(zzz)|Z]-Z,
    wf_input_parameter(PropsDl, ve(Version), VeDl),
    wf_input_parameter(PropsDl, br(Branch),  BrDl),
    plunit_coworkers_wf:append_dl(VeDl, PropsDl,  PropsDl2),
    plunit_coworkers_wf:append_dl(BrDl, PropsDl2, PropsDl3),
    PropsDl3 = [br(Branch), ve(Version),re(zzz)|X]-X.

% wf

test(wf_embedded_example, []) :-
    coworkers:workflow('release_project', [re('coworkers')]).

:- end_tests(coworkers_wf).

