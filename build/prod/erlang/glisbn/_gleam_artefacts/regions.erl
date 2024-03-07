-module(regions).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export_type([dataset/0]).

-type dataset() :: {regions, binary(), binary(), list(list(binary()))}.


