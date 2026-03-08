(* Install the SupabaseLink paclet from source *)

(* Build the paclet *)
result = PacletBuild[
    FileNameJoin[{DirectoryName[$InputFileName], ".."}]
];

Print["Build result: ", result];

(* Install the built paclet *)
pacletFile = File[FileNameJoin[{
    DirectoryName[$InputFileName], "..", "..", "build",
    "SupabaseLink-" <> PacletObject[File[
        FileNameJoin[{DirectoryName[$InputFileName], ".."}]
    ]]["Version"] <> ".paclet"
}]];

installed = PacletInstall[pacletFile, ForceVersionInstall -> True];
Print["Installed: ", installed];
