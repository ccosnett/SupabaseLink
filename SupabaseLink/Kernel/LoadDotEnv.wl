(* ::Package:: *)

BeginPackage["SupabaseLink`LoadDotEnv`"];
Unprotect["SupabaseLink`LoadDotEnv`*"]; ClearAll["SupabaseLink`LoadDotEnv`*"]; ClearAll["SupabaseLink`LoadDotEnv`Private`*"]; ClearSystemCache[];



Begin["`Private`"];
Needs["SupabaseLink`"];


(* loads environment variables from a .env file into the Wolfram Language session *)
(* handles key=value pairs (quoted or unquoted), comment lines, blank lines *)
(* no support for: multi-line values, variable expansion, `export` prefix, or UTF-8 BOM stripping *)
(* parsing strategy: strip comment lines (starting with #) and blank lines, then delegate *)
(* key=value parsing to ImportString[...,"Ini"], which treats the content as an INI-style file *)
LoadDotEnv::usage =
    "LoadDotEnv[] loads the .env file in the current working directory and returns an Association of key-value pairs.\n" <>
    "LoadDotEnv[path] loads the .env file at the given path.";

LoadDotEnv[] := LoadDotEnv[FileNameJoin[{Directory[], ".env"}]]

LoadDotEnv[path_String] := Module[{lines, stripped, content, parsed},
    If[! FileExistsQ[path],
        Message[LoadDotEnv::nofile, path];
        Return[$Failed]];
    lines = StringTrim /@ ReadList[path, String];
    lines = StringDelete[#, "\""] & /@ lines;
    stripped = Select[lines, ! StringStartsQ[#, "#"] && # =!= "" &];
    If[stripped === {}, Return[<||>]];
    content = StringRiffle[stripped, "\n"];
    parsed = ImportString[content, "Ini"]
]

(* error message *)
LoadDotEnv::nofile = "File not found: `1`.";


End[];
EndPackage[]
