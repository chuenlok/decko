include_set Abstract::ProsemirrorEditor
include_set Abstract::AceEditor

format :html do
  def editor
    card.rule(:input)
  end

  def editor_method editor_type
    "#{editor_type}_input"
  end

  def editor_defined_by_card
    return unless (editor_card = Card[editor])
    nest editor_card, view: :core
  end

  view :editor do
    try(editor_method(editor)) ||
      editor_defined_by_card ||
      send(editor_method(default_editor))
  end

  def default_editor
    :rich_text
  end

  # overriden by mods that provide rich text editors
  def rich_text_input
    prosemirror_editor_input
  end

  def plain_text_input
    text_area :content, rows: 5, class: "card-content",
              "data-card-type-code" => card.type_code
  end

  def phrase_input
    text_field :content, class: "card-content"
  end

  def date_input
    text_field :content, class: "date-editor"
  end
end
