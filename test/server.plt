user:da_server_test_marker_predicate.

dapipe(ServerIn, ServerOut, ClientIn, ClientOut) :-
    pipe(ServerIn, ClientOut),
    pipe(ClientIn, ServerOut),
    set_stream(ClientIn,  buffer(full)),
    set_stream(ClientIn,  encoding(octet)),
    set_stream(ClientIn,  newline(dos)),
    set_stream(ClientOut, buffer(false)),
    set_stream(ClientOut, encoding(octet)).

:- begin_tests(server).

:- use_module("../prolog/client.pl").
:- use_module("../prolog/server.pl").

test(disconnect, [ setup(dapipe(ServerIn, ServerOut, ClientIn, ClientOut)),
                   cleanup(( close(ServerIn),
                             close(ClientOut),
                             close(ClientIn),
                             close(ServerOut),
                             (   is_thread(ServerThreadId)
                             ->  thread_signal(ServerThreadId, thread_exit(1))
                             ;   true
                             )
                           )
                          )
                 ]
    ) :-
    thread_create(da_server([in(ServerIn), out(ServerOut)]), ServerThreadId, []),
    dap_request_response(ClientIn, ClientOut, "disconnect"),
    thread_join(ServerThreadId, exited(0)).

test(initialize, [ setup(dapipe(SIn, SOut, CIn, COut)),
                   cleanup(( close(SIn),
                             close(COut),
                             close(CIn),
                             close(SOut),
                             (   is_thread(ServerThreadId)
                             ->  thread_signal(ServerThreadId, thread_exit(1))
                             ;   true
                             )
                           )
                          )
                 ]
    ) :-
    thread_create(da_server([in(SIn), out(SOut)]), ServerThreadId, []),
    dap_request_response(CIn, COut, 1, "initialize", null, Body),
    _{ supportsConfigurationDoneRequest : true } :< Body,
    dap_request_response(CIn, COut, 2, "disconnect"),
    thread_join(ServerThreadId, exited(0)).

test(launch, [ setup(dapipe(SIn, SOut, CIn, COut)),
                   cleanup(( close(SIn),
                             close(COut),
                             close(CIn),
                             close(SOut),
                             (   is_thread(ServerThreadId)
                             ->  thread_signal(ServerThreadId, thread_exit(1))
                             ;   true
                             )
                           )
                          )
                 ]
    ) :-
    thread_create(da_server([in(SIn), out(SOut)]), ServerThreadId, []),
    dap_request_response(CIn, COut, 1, "initialize", null, Body),
    _{ supportsConfigurationDoneRequest : true } :< Body,
    source_file(user:da_server_test_marker_predicate, ThisFile),
    file_directory_name(ThisFile, CWD),
    debug(dap(test), "CWD: ~w", [CWD]),
    dap_request_response(CIn, COut, 2, "launch", _{ cwd    : CWD,
                                                    module : "target/foo.pl",
                                                    goal   : foo
                                                  }, [event(_, "initialized", _)|_],
                         _Body),
    dap_request_response(CIn, COut, 3, "disconnect"),
    thread_join(ServerThreadId, exited(0)).

test(configurationDone, [ setup(dapipe(SIn, SOut, CIn, COut)),
                          cleanup(( close(SIn),
                                    close(COut),
                                    close(CIn),
                                    close(SOut),
                                    (   is_thread(ServerThreadId)
                                    ->  thread_signal(ServerThreadId, thread_exit(1))
                                    ;   true
                                    )
                                  )
                                 )
                        ]
    ) :-
    thread_create(da_server([in(SIn), out(SOut)]), ServerThreadId, []),
    dap_request_response(CIn, COut, 1, "initialize", null, Body),
    _{ supportsConfigurationDoneRequest : true } :< Body,
    source_file(user:da_server_test_marker_predicate, ThisFile),
    file_directory_name(ThisFile, CWD),
    debug(dap(test), "CWD: ~w", [CWD]),
    dap_request_response(CIn, COut, 2, "launch", _{ cwd    : CWD,
                                                    module : "target/foo.pl",
                                                    goal   : foo
                                                  }, [event(_, "initialized", _)|_],
                         _Body),
    dap_request_response(CIn, COut, 3, "configurationDone"),
    dap_request_response(CIn, COut, 4, "disconnect"),
    thread_join(ServerThreadId, exited(0)).

:- end_tests(server).
