# coworkers
A simple DSL in Prolog to implement workflows as trees of coroutines

workflow('release_project', Props) :-

    wf(

        props( Props ),

            % data exchange between tasks happens through variable unification

            node(dialog('coordinator'),

                       [ node(task('sync git repo', [ParentRepoVersions]), []),

                         node(task('modify parent repo versions', [ParentRepoVersions]), [])

                       ])

    ).
