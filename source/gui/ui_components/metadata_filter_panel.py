"""Tkinter controls for filtering wallpapers by project metadata."""

from tkinter import Button, Entry, Frame, Label, StringVar
from tkinter import ttk
from collections.abc import Callable

from common.constants import UI_COLORS


class MetadataFilterPanel:
    """Collects filter values and notifies the gallery when they change."""

    def __init__(self, parent, on_apply: Callable[[dict | None], None]):
        self.on_apply = on_apply
        self.frame = Frame(parent, bg=UI_COLORS["bg_secondary"], bd=2, relief="solid")
        self.type_value = StringVar()
        self.tags_any_value = StringVar()
        self.tags_all_value = StringVar()
        self.tags_not_value = StringVar()
        self.type_box = ttk.Combobox(self.frame, textvariable=self.type_value, values=("", "scene", "video", "web", "application"), state="readonly", width=15)
        self.tags_any_entry = Entry(self.frame, textvariable=self.tags_any_value, width=18)
        self.tags_all_entry = Entry(self.frame, textvariable=self.tags_all_value, width=18)
        self.tags_not_entry = Entry(self.frame, textvariable=self.tags_not_value, width=18)
        self._build_widgets()

    def _build_widgets(self) -> None:
        Label(self.frame, text="FILTER", bg=UI_COLORS["bg_secondary"], fg=UI_COLORS["fg_text"], font=("Arial", 10, "bold")).grid(column=0, row=0, columnspan=2, sticky="w", padx=5, pady=(5, 2))
        Label(self.frame, text="TYPE", bg=UI_COLORS["bg_secondary"], fg=UI_COLORS["fg_text"]).grid(column=0, row=1, sticky="w", padx=5, pady=2)
        self.type_box.grid(column=1, row=1, padx=5, pady=2)
        for row, label, widget in (
            (2, "TAGS ANY", self.tags_any_entry),
            (3, "TAGS ALL", self.tags_all_entry),
            (4, "TAGS NOT", self.tags_not_entry),
        ):
            Label(self.frame, text=label, bg=UI_COLORS["bg_secondary"], fg=UI_COLORS["fg_text"]).grid(column=0, row=row, sticky="w", padx=5, pady=2)
            widget.grid(column=1, row=row, padx=5, pady=2)
        Button(self.frame, text="APPLY", command=self.apply, bg=UI_COLORS["accent_blue"], fg=UI_COLORS["fg_text"], cursor="hand2").grid(column=0, row=5, padx=5, pady=5)
        Button(self.frame, text="CLEAR", command=self.clear, bg=UI_COLORS["button_cancel"], fg=UI_COLORS["fg_text"], cursor="hand2").grid(column=1, row=5, padx=5, pady=5)

    def _split_tags(self, value: str) -> list[str]:
        return [tag.strip() for tag in value.split(",") if tag.strip()]

    def get_ast(self) -> dict | None:
        terms = []
        if self.type_value.get():
            terms.append({"field": "type", "value": self.type_value.get()})
        for value, operation in ((self.tags_any_value.get(), "OR"), (self.tags_all_value.get(), "AND")):
            tags = self._split_tags(value)
            if tags:
                tag_terms = [{"field": "tags", "value": tag} for tag in tags]
                terms.append(tag_terms[0] if len(tag_terms) == 1 else {"op": operation, "terms": tag_terms})
        for tag in self._split_tags(self.tags_not_value.get()):
            terms.append({"op": "NOT", "term": {"field": "tags", "value": tag}})
        if not terms:
            return None
        return terms[0] if len(terms) == 1 else {"op": "AND", "terms": terms}

    def apply(self) -> None:
        self.on_apply(self.get_ast())

    def clear(self) -> None:
        self.type_value.set("")
        self.tags_any_value.set("")
        self.tags_all_value.set("")
        self.tags_not_value.set("")
        self.on_apply(None)

    def grid(self, **kwargs) -> None:
        self.frame.grid(**kwargs)
