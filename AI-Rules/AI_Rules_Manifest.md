# AI Rules Manifest

> **AI Assist Disclosure:** This document was generated with AI assistance (Claude),
> reviewed and refined by Jim The STEAM Clown, and validated against STEAM Clown documentation rules.
> Content accuracy has not yet been fully verified — use with appropriate judgment.

This file is the single lookup table for every AI rules file in this project. Fetch this file eagerly at the start of every chat. Do not fetch every row's target file eagerly — only fetch a target file when the trigger condition is met, per the gate rule in `AI_Rules_Top_Level_Projects.md`.

## Always-Active Rules

These apply to every chat regardless of language or platform. Fetch at chat start.

| Rule File | Path | Status |
|---|---|---|
| Top Level Projects | [AI_Rules_Top_Level_Projects.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/%F0%9F%A7%A0AI_Rules_Top_Level_Projects.md) | active |
| AI-to-User Communication Style | [AI_Rules_AI_2_User_Communication_Style.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_AI_2_User_Communication_Style.md) | active |
| Documentation Projects | [AI_Rules_Documentation_Projects.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Documentation_Projects.md) | active |
| Top Level Coding Rules | [AI_Rules_Top_Level_Coding_Rules.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Top_Level_Coding_Rules.md) | active |

## Language-Triggered Rules

Fetch when the matching trigger is present: a file extension in the project, a language named in the request, or code being generated in that language.

| Rule File | Path | Trigger | Status |
|---|---|---|---|
| Python Rules | [AI_Rules_Python_Language_Projects.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Python_Language_Projects.md) | `.py` files, "Python" requested | active |
| PHP Rules | AI_Coding_PHP_Rules.md | `.php` files, "PHP" requested | planned |
| C++/Arduino Rules | AI_Coding_C-PlusPlus_Rules.md | `.cpp`, `.ino` files, "Arduino" requested | planned |
| Java Rules | AI_Coding_Java_Rules.md | `.java` files, "Java" requested | planned |
| JavaScript Rules | AI_Coding_JavaScript_Rules.md | `.js` files, "JavaScript" requested | planned |
| CSS Rules | AI_Coding_CSS_Rules.md | `.css` files, "CSS" requested | planned |

## Platform-Triggered Rules

| Rule File | Path | Trigger | Status |
|---|---|---|---|
| Web Projects | [AI_Rules_Web_Projects.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Web_Projects.md) | web app, HTML/CSS/JS/PHP project context | active |
| Embedded/Robotics Rules | AI_Coding_Embedded_Robotics_Rules.md | GPIO, serial bus, sensor/actuator code | planned |
| Raspberry Pi Rules | AI_Coding_RaspberryPi_Rules.md | Raspberry Pi target | planned |
| Arduino Rules | AI_Coding_Arduino_Rules.md | Arduino target | planned |

## Notes

- "planned" rows have no working hyperlink yet. If a trigger fires for a planned row, say so explicitly instead of fetching or guessing at content.
- When a language- or platform-specific file conflicts with `AI_Rules_Top_Level_Coding_Rules.md`, the more specific file wins for its scope, per that file's own precedence statement.
- Add new rows to this manifest whenever a new rule file is created. This file is the single source of truth for what exists — the prose links inside other rule files are secondary and may go stale.

## Sources

- [AI_Rules_Top_Level_Projects.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/%F0%9F%A7%A0AI_Rules_Top_Level_Projects.md)
- [AI_Rules_Top_Level_Coding_Rules.md](https://raw.githubusercontent.com/jimTheSTEAMClown/Robots-Rovers-Project-Template/refs/heads/main/AI-Rules/AI_Rules_Top_Level_Coding_Rules.md)
