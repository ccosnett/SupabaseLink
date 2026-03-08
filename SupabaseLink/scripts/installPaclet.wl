(* installPaclet.wl
   Build and install the SupabaseLink paclet locally.

   Usage (from repo root):
     wolframscript -file scripts/installPaclet.wl

   Or from within a Mathematica notebook:
     Get["/path/to/SupabaseLink/scripts/installPaclet.wl"]
*)

Module[{repoRoot, pacletDir, buildResult, pacletFile},

  (* Resolve the repo root relative to this script's location *)
  repoRoot  = DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
  pacletDir = FileNameJoin[{repoRoot, "SupabaseLink"}];

  Print["Building paclet from: ", pacletDir];

  (* PacletBuild creates a .paclet archive under build/ *)
  buildResult = PacletBuild[pacletDir];

  If[FailureQ[buildResult],
    Print["Build FAILED: ", buildResult];
    Exit[1]
  ];

  pacletFile = buildResult["Location"];
  Print["Built: ", pacletFile];

  (* Install into the local paclet repository *)
  PacletInstall[pacletFile, ForceVersionInstall -> True];

  Print["Installed SupabaseLink successfully."];
  Print["Load with:  << SupabaseLink`"];
]
