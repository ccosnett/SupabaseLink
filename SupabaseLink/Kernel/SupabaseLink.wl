(*

PacletDirectoryLoad[NotebookDirectory[]];
Get["SupabaseLink`"] // Quiet;
?? SupabaseLink`*

*)

(* comment to test if claude code review works *)
(* comment to test if claude code review works *)


Print["loaded paclet: SupabaseLink"];
(* ::Package:: *)

(* :Title: SupabaseLink *)
(* :Context: SupabaseLink` *)
(* :Authors: Conor Cosnett *)
(* :Date: 2026-03-09 *)


BeginPackage["SupabaseLink`"];
Unprotect["SupabaseLink`*"]; ClearAll["SupabaseLink`*"]; ClearAll["SupabaseLink`Private`*"]; ClearSystemCache[];


(* LoadDotEnv` *)
LoadDotEnv

(* SupabaseLink public symbols *)
$SupabaseURL
$SupabaseAPIKey
SupabaseConnect
SupabaseSelect
SupabaseInsert
SupabaseUpdate
SupabaseDelete
SupabaseRPC


Get["SupabaseLink`SupabaseConnect`"];
Get["SupabaseLink`LoadDotEnv`"];

EndPackage[];
