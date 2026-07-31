#!/usr/bin/env osascript
-- Click common Shortcuts import / trust dialog buttons (EN + FR).
-- Stdout: CLICKED:<name> | NONE | ERROR:<msg>
-- Requires Accessibility for the host running osascript (Cursor / Terminal).

on buttonNames()
	-- FR UI uses "Ajouter ce raccourci" on the signed-file import sheet.
	return {"Add Shortcut", "Add This Shortcut", "Add Untrusted Shortcut", "Add Anyway", "Allow", "OK", "Continue", "Get Shortcut", "Ajouter ce raccourci", "Ajouter le raccourci", "Ajouter un raccourci", "Ajouter le raccourci non fiable", "Ajouter quand même", "Autoriser", "Continuer", "Obtenir le raccourci"}
end buttonNames

on clickMatchingButton(targetProcess)
	tell application "System Events"
		tell process targetProcess
			set candidates to my buttonNames()
			repeat with w in windows
				repeat with bName in candidates
					try
						if exists button (bName as text) of w then
							click button (bName as text) of w
							return "CLICKED:" & (bName as text)
						end if
					end try
					try
						if exists sheet 1 of w then
							if exists button (bName as text) of sheet 1 of w then
								click button (bName as text) of sheet 1 of w
								return "CLICKED:" & (bName as text)
							end if
						end if
					end try
				end repeat
				try
					repeat with bName in candidates
						set matches to (every button of entire contents of w whose name is (bName as text))
						if (count of matches) > 0 then
							click item 1 of matches
							return "CLICKED:" & (bName as text)
						end if
					end repeat
				end try
			end repeat
		end tell
	end tell
	return "NONE"
end clickMatchingButton

on run argv
	set procName to "Shortcuts"
	if (count of argv) ≥ 1 then set procName to item 1 of argv
	try
		tell application "System Events"
			if not (exists process procName) then
				return "ERROR:process_missing:" & procName
			end if
		end tell
		return my clickMatchingButton(procName)
	on error errMsg number errNum
		return "ERROR:" & errNum & ":" & errMsg
	end try
end run
