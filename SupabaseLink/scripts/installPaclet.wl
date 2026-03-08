(* installPaclet.wl - Build and install the SupabaseLink paclet *)

(* Resolve the paclet root directory relative to this script *)
$pacletDir = FileNameJoin[{DirectoryName[$InputFileName], ".."}];

(* Build the paclet (.paclet archive) *)
buildResult = PacletBuild[$pacletDir];

(* Install the built paclet into the local Wolfram paclet repository *)
PacletInstall[buildResult["Location"]]
