(*
LoadDotEnv[] Loads environment variables from .env files into a Wolfram Language session.
Handles the basic case: key=value pairs (quoted or unquoted), comment lines, blank lines.
No support yet for: multi-line values, variable expansion, the `export` prefix, or UTF-8 BOM stripping.
Parsing strategy: strip comment lines (starting with #) and blank lines, then delegate
key=value parsing to ImportString[...,"Ini"], which treats the content as an INI-style file.
This avoids reimplementing what the built-in importer already does correctly.
*)

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

LoadDotEnv::nofile = "File not found: `1`."
