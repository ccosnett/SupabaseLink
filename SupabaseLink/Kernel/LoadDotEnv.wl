(* ::Package:: *)

(* :Title: LoadDotEnv *)
(* :Context: SupabaseLink` *)
(* :Authors: Conor Cosnett *)
(* :Date: 2026-03-09 *)

(* loads environment variables from a .env file and returns a flat Association *)
(* handles key=value pairs (quoted or unquoted), comment lines, blank lines *)
(* no support for: multi-line values, variable expansion, `export` prefix *)


BeginPackage["SupabaseLink`"];

LoadDotEnv::usage =
    "LoadDotEnv[] loads the .env file in the current working directory and returns a flat Association of key->value pairs.\n" <>
    "LoadDotEnv[path] loads from a specific path.";

LoadDotEnv::nofile = "File not found: `1`.";


Begin["`Private`"];

LoadDotEnv[] := LoadDotEnv[FileNameJoin[{Directory[], ".env"}]]

LoadDotEnv[path_String] := Module[{lines, stripped},
    If[!FileExistsQ[path],
        Message[LoadDotEnv::nofile, path];
        Return[$Failed]];
    lines = StringTrim /@ ReadList[path, String];
    lines = StringDelete[#, "\""] & /@ lines;
    stripped = Select[lines, !StringStartsQ[#, "#"] && StringContainsQ[#, "="] &];
    If[stripped === {}, Return[<||>]];
    Association[Rule @@@ (StringSplit[#, "=", 2] & /@ stripped)]
]

End[];
EndPackage[];
