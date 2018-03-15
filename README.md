# coworkers
A simple DSL in Prolog to implement workflows as trees of coroutines

# example
workflow('release_project', Props) :-

    wf(

        props( Props ), module(workflow_module),

            % data exchange between tasks happens through variable unification

            node(dialog('coordinator'),

                       [ node(task('sync git repo', [ParentRepoVersions]), []),

                         node(task('modify parent repo versions', [ParentRepoVersions]), [])

                       ])

    ).

# description
Assuming that:
- tasks and dialogs are available in a user's module workflow_module
- tasks make use of wf_ask_parameter to ask for some input, at whichever stage of completion they are in,
    before they get resumed
- dialogs make use of wf_input_parameter to augment the actual workflow's known props, and get called
    only when required
the defined workflow resembles that of some coworkers in an office.

# current limitations
- tasks under a dialog get called sequentially
- workflows are not persistent