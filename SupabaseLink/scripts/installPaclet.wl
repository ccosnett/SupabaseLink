(* ::Package:: *)

(* installPaclet.wl — build and install the SupabaseLink paclet *)
(*
    Usage (from the repo root):
        wolframscript -file SupabaseLink/scripts/installPaclet.wl
*)

(* Resolve the paclet source directory relative to this script *)
$pacletDir = FileNameJoin[{DirectoryName[$InputFileName], ".."}]

Print["Building paclet from: ", $pacletDir]

(* Build the .paclet archive *)
$result = PacletBuild[$pacletDir]

If[FailureQ[$result],
    Print["PacletBuild failed: ", $result];
    Exit[1]
]

$pacletFile = $result["Location"]
Print["Built: ", $pacletFile]

(* Install into the local paclet repository *)
PacletInstall[$pacletFile, ForceVersionInstall -> True]

Print["SupabaseLink installed successfully."]
Print["Load with:  Needs[\"SupabaseLink`\"]"]
