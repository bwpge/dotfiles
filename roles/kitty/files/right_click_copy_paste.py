from kittens.tui.handler import result_handler

from kitty.boss import Boss
from kitty.clipboard import get_clipboard_string


def main(args: list[str]) -> str:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    # copy to clipboard if we have a selection, then clear it
    if w.has_selection():
        w.copy_to_clipboard()
        w.clear_selection()

    # otherwise paste from clipboard
    else:
        text = get_clipboard_string()
        if text:
            w.paste_text(text)
