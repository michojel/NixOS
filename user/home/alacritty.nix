{ config, pkgs, lib, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "MesloLGM Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "MesloLGM Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "MesloLGM Nerd Font";
          style = "Italic";
        };
        size = 11.0;
      };

      key_bindings = [
        # Key bindings
        #
        # Key bindings are specified as a list of objects. For example, this is the
        # default paste binding:
        #
        # `- { key: V, mods: Control|Shift, action: Paste }`
        #
        # Each key binding will specify a:
        #
        # - `key`: Identifier of the key pressed
        #
        #    - A-Z
        #    - F1-F24
        #    - Key0-Key9
        #
        #    A full list with available key codes can be found here:
        #    https://docs.rs/winit/*/winit/event/enum.VirtualKeyCode.html#variants
        #
        #    Instead of using the name of the keys, the `key` field also supports using
        #    the scancode of the desired key. Scancodes have to be specified as a
        #    decimal number. This command will allow you to display the hex scancodes
        #    for certain keys:
        #
        #       `showkey --scancodes`.
        #
        # Then exactly one of:
        #
        # - `chars`: Send a byte sequence to the running application
        #
        #    The `chars` field writes the specified string to the terminal. This makes
        #    it possible to pass escape sequences. To find escape codes for bindings
        #    like `PageUp` (`"\x1b[5~"`), you can run the command `showkey -a` outside
        #    of tmux. Note that applications use terminfo to map escape sequences back
        #    to keys. It is therefore required to update the terminfo when changing an
        #    escape sequence.
        #
        # - `action`: Execute a predefined action
        #
        #   - ToggleViMode
        #   - SearchForward
        #       Start searching toward the right of the search origin.
        #   - SearchBackward
        #       Start searching toward the left of the search origin.
        #   - Copy
        #   - Paste
        #   - IncreaseFontSize
        #   - DecreaseFontSize
        #   - ResetFontSize
        #   - ScrollPageUp
        #   - ScrollPageDown
        #   - ScrollHalfPageUp
        #   - ScrollHalfPageDown
        #   - ScrollLineUp
        #   - ScrollLineDown
        #   - ScrollToTop
        #   - ScrollToBottom
        #   - ClearHistory
        #       Remove the terminal's scrollback history.
        #   - Hide
        #       Hide the Alacritty window.
        #   - Minimize
        #       Minimize the Alacritty window.
        #   - Quit
        #       Quit Alacritty.
        #   - ToggleFullscreen
        #   - ToggleMaximized
        #   - SpawnNewInstance
        #       Spawn a new instance of Alacritty.
        #   - CreateNewWindow
        #       Create a new Alacritty window from the current process.
        #   - ClearLogNotice
        #       Clear Alacritty's UI warning and error notice.
        #   - ClearSelection
        #       Remove the active selection.
        #   - ReceiveChar
        #   - None
        #
        # - Vi mode exclusive actions:
        #
        #   - Open
        #       Perform the action of the first matching hint under the vi mode cursor
        #       with `mouse.enabled` set to `true`.
        #   - ToggleNormalSelection
        #   - ToggleLineSelection
        #   - ToggleBlockSelection
        #   - ToggleSemanticSelection
        #       Toggle semantic selection based on `selection.semantic_escape_chars`.
        #   - CenterAroundViCursor
        #       Center view around vi mode cursor
        #
        # - Vi mode exclusive cursor motion actions:
        #
        #   - Up
        #       One line up.
        #   - Down
        #       One line down.
        #   - Left
        #       One character left.
        #   - Right
        #       One character right.
        #   - First
        #       First column, or beginning of the line when already at the first column.
        #   - Last
        #       Last column, or beginning of the line when already at the last column.
        #   - FirstOccupied
        #       First non-empty cell in this terminal row, or first non-empty cell of
        #       the line when already at the first cell of the row.
        #   - High
        #       Top of the screen.
        #   - Middle
        #       Center of the screen.
        #   - Low
        #       Bottom of the screen.
        #   - SemanticLeft
        #       Start of the previous semantically separated word.
        #   - SemanticRight
        #       Start of the next semantically separated word.
        #   - SemanticLeftEnd
        #       End of the previous semantically separated word.
        #   - SemanticRightEnd
        #       End of the next semantically separated word.
        #   - WordLeft
        #       Start of the previous whitespace separated word.
        #   - WordRight
        #       Start of the next whitespace separated word.
        #   - WordLeftEnd
        #       End of the previous whitespace separated word.
        #   - WordRightEnd
        #       End of the next whitespace separated word.
        #   - Bracket
        #       Character matching the bracket at the cursor's location.
        #   - SearchNext
        #       Beginning of the next match.
        #   - SearchPrevious
        #       Beginning of the previous match.
        #   - SearchStart
        #       Start of the match to the left of the vi mode cursor.
        #   - SearchEnd
        #       End of the match to the right of the vi mode cursor.
        #
        # - Search mode exclusive actions:
        #   - SearchFocusNext
        #       Move the focus to the next search match.
        #   - SearchFocusPrevious
        #       Move the focus to the previous search match.
        #   - SearchConfirm
        #   - SearchCancel
        #   - SearchClear
        #       Reset the search regex.
        #   - SearchDeleteWord
        #       Delete the last word in the search regex.
        #   - SearchHistoryPrevious
        #       Go to the previous regex in the search history.
        #   - SearchHistoryNext
        #       Go to the next regex in the search history.
        #
        # - macOS exclusive actions:
        #   - ToggleSimpleFullscreen
        #       Enter fullscreen without occupying another space.
        #
        # - Linux/BSD exclusive actions:
        #
        #   - CopySelection
        #       Copy from the selection buffer.
        #   - PasteSelection
        #       Paste from the selection buffer.
        #
        # - `command`: Fork and execute a specified command plus arguments
        #
        #    The `command` field must be a map containing a `program` string and an
        #    `args` array of command line parameter strings. For example:
        #       `{ program: "alacritty", args: ["-e", "vttest"] }`
        #
        # And optionally:
        #
        # - `mods`: Key modifiers to filter binding actions
        #
        #    - Command
        #    - Control
        #    - Option
        #    - Super
        #    - Shift
        #    - Alt
        #
        #    Multiple `mods` can be combined using `|` like this:
        #       `mods: Control|Shift`.
        #    Whitespace and capitalization are relevant and must match the example.
        #
        # - `mode`: Indicate a binding for only specific terminal reported modes
        #
        #    This is mainly used to send applications the correct escape sequences
        #    when in different modes.
        #
        #    - AppCursor
        #    - AppKeypad
        #    - Search
        #    - Alt
        #    - Vi
        #
        #    A `~` operator can be used before a mode to apply the binding whenever
        #    the mode is *not* active, e.g. `~Alt`.
        #
        # Bindings are always filled by default, but will be replaced when a new
        # binding with the same triggers is defined. To unset a default binding, it can
        # be mapped to the `ReceiveChar` action. Alternatively, you can use `None` for
        # a no-op if you do not wish to receive input characters for that binding.
        #
        # If the same trigger is assigned to multiple actions, all of them are executed
        # in the order they were defined in.
        #key_bindings:
        #- { key: Paste,                                       action: Paste          }
        #- { key: Copy,                                        action: Copy           }
        #- { key: L,         mods: Control,                    action: ClearLogNotice }
        #- { key: L,         mods: Control, mode: ~Vi|~Search, chars: "\x0c"; }
        #- { key: PageUp,    mods: Shift,   mode: ~Alt,        action: ScrollPageUp   }
        #- { key: PageDown,  mods: Shift,   mode: ~Alt,        action: ScrollPageDown }
        #- { key: Home,      mods: Shift,   mode: ~Alt,        action: ScrollToTop    }
        #- { key: End,       mods: Shift,   mode: ~Alt,        action: ScrollToBottom }

        # Font size
        { key = "Plus"; mods = "Control|Shift"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control|Shift"; action = "DecreaseFontSize"; }
        { key = "Underline"; mods = "Control|Shift"; action = "DecreaseFontSize"; }
        {
          key = 11; # Key0
          mods = "Control|Shift";
          action = "ResetFontSize";
        }

        # Vi Mode
        { key = "Space"; mods = "Shift|Control"; mode = "~Search"; action = "ToggleViMode"; }
        { key = "Space"; mods = "Shift|Control"; mode = "Vi|~Search"; action = "ScrollToBottom"; }
        { key = "Escape"; mode = "Vi|~Search"; action = "ClearSelection"; }
        { key = "I"; mode = "Vi|~Search"; action = "ToggleViMode"; }
        { key = "I"; mode = "Vi|~Search"; action = "ScrollToBottom"; }
        { key = "C"; mods = "Control"; mode = "Vi|~Search"; action = "ToggleViMode"; }
        { key = "Y"; mods = "Control"; mode = "Vi|~Search"; action = "ScrollLineUp"; }
        { key = "E"; mods = "Control"; mode = "Vi|~Search"; action = "ScrollLineDown"; }
        { key = "G"; mode = "Vi|~Search"; action = "ScrollToTop"; }
        { key = "G"; mods = "Shift"; mode = "Vi|~Search"; action = "ScrollToBottom"; }
        { key = "B"; mods = "Control"; mode = "Vi|~Search"; action = "ScrollPageUp"; }
        { key = "F"; mods = "Control"; mode = "Vi|~Search"; action = "ScrollPageDown"; }
        { key = "U"; mods = "Control"; mode = "Vi|~Search"; action = "ScrollHalfPageUp"; }
        { key = "D"; mods = "Control"; mode = "Vi|~Search"; action = "ScrollHalfPageDown"; }
        { key = "Y"; mode = "Vi|~Search"; action = "Copy"; }
        { key = "Y"; mode = "Vi|~Search"; action = "ClearSelection"; }
        { key = "Copy"; mode = "Vi|~Search"; action = "ClearSelection"; }
        { key = "V"; mode = "Vi|~Search"; action = "ToggleNormalSelection"; }
        { key = "V"; mods = "Shift"; mode = "Vi|~Search"; action = "ToggleLineSelection"; }
        { key = "V"; mods = "Control"; mode = "Vi|~Search"; action = "ToggleBlockSelection"; }
        { key = "V"; mods = "Alt"; mode = "Vi|~Search"; action = "ToggleSemanticSelection"; }
        { key = "Return"; mode = "Vi|~Search"; action = "Open"; }
        { key = "Z"; mode = "Vi|~Search"; action = "CenterAroundViCursor"; }
        { key = "K"; mode = "Vi|~Search"; action = "Up"; }
        { key = "J"; mode = "Vi|~Search"; action = "Down"; }
        { key = "H"; mode = "Vi|~Search"; action = "Left"; }
        { key = "L"; mode = "Vi|~Search"; action = "Right"; }
        { key = "Up"; mode = "Vi|~Search"; action = "Up"; }
        { key = "Down"; mode = "Vi|~Search"; action = "Down"; }
        { key = "Left"; mode = "Vi|~Search"; action = "Left"; }
        { key = "Right"; mode = "Vi|~Search"; action = "Right"; }
        { key = "Key0"; mode = "Vi|~Search"; action = "First"; }
        {
          key = 5; # $
          mods = "Shift";
          mode = "Vi|~Search";
          action = "Last";
        }
        {
          key = 7; # ^
          mods = "Shift";
          mode = "Vi|~Search";
          action = "FirstOccupied";
        }
        { key = "H"; mods = "Shift"; mode = "Vi|~Search"; action = "High"; }
        { key = "M"; mods = "Shift"; mode = "Vi|~Search"; action = "Middle"; }
        { key = "L"; mods = "Shift"; mode = "Vi|~Search"; action = "Low"; }
        { key = "B"; mode = "Vi|~Search"; action = "SemanticLeft"; }
        { key = "W"; mode = "Vi|~Search"; action = "SemanticRight"; }
        { key = "E"; mode = "Vi|~Search"; action = "SemanticRightEnd"; }
        { key = "B"; mods = "Shift"; mode = "Vi|~Search"; action = "WordLeft"; }
        { key = "W"; mods = "Shift"; mode = "Vi|~Search"; action = "WordRight"; }
        { key = "E"; mods = "Shift"; mode = "Vi|~Search"; action = "WordRightEnd"; }
        {
          key = 5; # %
          mods = "Shift";
          mode = "Vi|~Search";
          action = "Bracket";
        }
        { key = "Slash"; mode = "Vi|~Search"; action = "SearchForward"; }
        {
          key = 53; # /
          mods = "Shift";
          mode = "Vi|~Search";
          action = "SearchBackward";
        }
        { key = "N"; mode = "Vi|~Search"; action = "SearchNext"; }
        { key = "N"; mods = "Shift"; mode = "Vi|~Search"; action = "SearchPrevious"; }

        # Search Mode
        { key = "Return"; mode = "Search|Vi"; action = "SearchConfirm"; }
        { key = "Escape"; mode = "Search"; action = "SearchCancel"; }
        { key = "C"; mods = "Control"; mode = "Search"; action = "SearchCancel"; }
        { key = "U"; mods = "Control"; mode = "Search"; action = "SearchClear"; }
        { key = "W"; mods = "Control"; mode = "Search"; action = "SearchDeleteWord"; }
        { key = "P"; mods = "Control"; mode = "Search"; action = "SearchHistoryPrevious"; }
        { key = "N"; mods = "Control"; mode = "Search"; action = "SearchHistoryNext"; }
        { key = "Up"; mode = "Search"; action = "SearchHistoryPrevious"; }
        { key = "Down"; mode = "Search"; action = "SearchHistoryNext"; }
        { key = "Return"; mode = "Search|~Vi"; action = "SearchFocusNext"; }
        { key = "Return"; mods = "Shift"; mode = "Search|~Vi"; action = "SearchFocusPrevious"; }

      ];
    };
  };
}
